import type { Plugin, PluginInput } from "@opencode-ai/plugin"
import { existsSync, readFileSync } from "node:fs"

// Shell handle from the opencode plugin API. PluginInput["$"] is the cleanest
// public type alias; @opencode-ai/plugin does not re-export BunShell directly.
type Shell = PluginInput["$"]

type ShellResult = {
  stdout?: unknown
  stderr?: unknown
  exitCode?: number
}

// Commit options whose value lives in the next token rather than fused
// (e.g. `--message foo`, `-m foo`). Options whose value can ONLY be fused
// (`-S[<keyid>]`, `--gpg-sign[=<keyid>]`) deliberately stay out: git itself
// treats `git commit -S KEY` as `-S` followed by pathspec `KEY`, and the
// parser must agree with git's semantics rather than guess.
const commitOptionsWithValues = new Set(["--author", "--cleanup", "--date", "--file", "--fixup", "--message", "--reuse-message", "--reedit-message", "--squash", "--trailer", "--pathspec-from-file", "-C", "-F", "-c", "-m"])

export function getShellCommand(args: unknown): string | undefined {
  if (!args || typeof args !== "object") return undefined
  const command = (args as Record<string, unknown>).command
  if (typeof command !== "string") return undefined
  const trimmed = command.trim()
  return trimmed.length > 0 ? trimmed : undefined
}

export function matchesGitAddArtifactCommand(command: string): boolean {
  const words = shellWords(command)
  const start = gitSubcommandArgsStart(words, "add")
  if (start === undefined) return false
  return words.slice(start).some(isArtifactPath)
}

export function matchesBroadGitAddCommand(command: string): boolean {
  const words = shellWords(command)
  const start = gitSubcommandArgsStart(words, "add")
  if (start === undefined) return false
  return words.slice(start).some(isBroadAddPathspec)
}

export function matchesGitCommitCommand(command: string): boolean {
  return gitSubcommandArgsStart(shellWords(command), "commit") !== undefined
}

export function matchesGitCommitAllCommand(command: string): boolean {
  if (!matchesGitCommitCommand(command)) return false
  const words = shellWords(command)
  const start = gitSubcommandArgsStart(words, "commit")
  if (start === undefined) return false
  for (let index = start; index < words.length; index += 1) {
    const word = words[index] ?? ""
    if (isShellSeparator(word) || word === "--") return false
    if (word === "--all") return true
    if (hasShortOption(word, "a")) return true
    if (commitOptionConsumesValue(word)) index += 1
  }
  return false
}

export function matchesGitCommitArtifactCommand(command: string): boolean {
  if (!matchesGitCommitCommand(command)) return false
  const words = shellWords(command)
  const start = gitSubcommandArgsStart(words, "commit")
  if (start === undefined) return false
  let pathspecMode = false
  for (let index = start; index < words.length; index += 1) {
    const word = words[index] ?? ""
    if (isShellSeparator(word)) return false
    if (!pathspecMode && word === "--") {
      pathspecMode = true
      continue
    }
    if (!pathspecMode && word.startsWith("-")) {
      if (commitOptionConsumesValue(word)) index += 1
      continue
    }
    if (isArtifactPath(word)) return true
  }
  return false
}

export function matchesGithubCurlCommand(command: string): boolean {
  return /(^|[;&|]\s*)curl\b/i.test(command) && /(^|[\s'"])(https?:\/\/)?([^\s/'"]*\.)?github\.com\b/i.test(command)
}

export function extractEditedFilePaths(tool: string, args: unknown): string[] {
  if (!args || typeof args !== "object") return []
  const normalizedTool = tool.toLowerCase()
  const record = args as Record<string, unknown>
  if (["edit", "write"].includes(normalizedTool)) {
    for (const key of ["filePath", "file_path", "path", "filename"]) {
      const value = record[key]
      if (typeof value === "string" && isMarkdownPath(value)) return [value]
    }
    return []
  }
  if (normalizedTool === "apply_patch") {
    const patchText = record.patchText
    if (typeof patchText !== "string") return []
    const paths: string[] = []
    for (const match of patchText.matchAll(/^\*\*\* (?:Add|Update|Delete) File: (.+)$/gm)) {
      const filePath = match[1]?.trim()
      if (filePath && isMarkdownPath(filePath)) paths.push(filePath)
    }
    for (const match of patchText.matchAll(/^\*\*\* Move to: (.+)$/gm)) {
      const filePath = match[1]?.trim()
      if (filePath && isMarkdownPath(filePath)) paths.push(filePath)
    }
    return paths
  }
  return []
}

// Heuristic hard-wrap detector for Markdown prose. Flags a paragraph when
// two consecutive prose lines look like the first was wrapped near a typical
// editor column. Known limitation: paragraphs whose first line exceeds 120
// characters fall outside the window and are not flagged. The warning is
// advisory, so a missed case is acceptable but a false positive on long
// single-line paragraphs is not.
export function detectHardWrappedMarkdown(markdown: string): { count: number; firstLine: number } | undefined {
  let inFence = false
  let inFrontmatter = false
  let previousWasProse = false
  let previousLength = 0
  let previousEndedMidSentence = false
  let count = 0
  let firstLine = 0
  const lines = markdown.split(/\r?\n/)

  for (let index = 0; index < lines.length; index += 1) {
    const lineNumber = index + 1
    const line = lines[index] ?? ""
    const trimmed = line.trimStart()

    if (lineNumber === 1 && /^---\s*$/.test(line)) {
      inFrontmatter = true
      previousWasProse = false
      continue
    }
    if (inFrontmatter) {
      if (/^---\s*$/.test(line)) inFrontmatter = false
      previousWasProse = false
      continue
    }
    if (/^\s*(```|~~~)/.test(line)) {
      inFence = !inFence
      previousWasProse = false
      continue
    }
    if (inFence) {
      previousWasProse = false
      continue
    }

    const prose = isProseLine(trimmed)
    if (previousWasProse && prose && previousLength >= 64 && previousLength <= 120 && previousEndedMidSentence) {
      count += 1
      if (firstLine === 0) firstLine = lineNumber - 1
    }

    const rightTrimmed = line.trimEnd()
    previousWasProse = prose
    previousLength = rightTrimmed.length
    previousEndedMidSentence = /[A-Za-z0-9,]$/.test(rightTrimmed)
  }

  return count > 0 ? { count, firstLine } : undefined
}

function isMarkdownPath(filePath: string): boolean {
  return /\.md(?:own)?$/i.test(filePath) || /\.markdown$/i.test(filePath)
}

// Minimal shell tokenizer. Quoted strings preserve their contents verbatim;
// `;`, `|`, and `&` are tokenized as standalone separators. `&&` and `||`
// therefore tokenize as two single-character tokens, which is acceptable
// because the only consumers look for `git` as a separate word and treat any
// separator as a hard reset. Command substitution (`$(...)`, backticks),
// redirections, and here-docs are intentionally not parsed; LLM-built
// commands that try to smuggle artifact paths through substitution are out of
// scope for this guard.
function shellWords(command: string): string[] {
  const words: string[] = []
  let current = ""
  let quote: string | undefined
  let escaped = false

  for (const char of command) {
    if (escaped) {
      current += char
      escaped = false
      continue
    }
    if (char === "\\" && quote !== "'") {
      escaped = true
      continue
    }
    if (quote) {
      if (char === quote) quote = undefined
      else current += char
      continue
    }
    if (char === "'" || char === '"') {
      quote = char
      continue
    }
    if (/\s/.test(char)) {
      if (current) {
        words.push(current)
        current = ""
      }
      continue
    }
    if (char === ";" || char === "|" || char === "&") {
      if (current) {
        words.push(current)
        current = ""
      }
      words.push(char)
      continue
    }
    current += char
  }

  if (current) words.push(current)
  return words
}

function gitSubcommandArgsStart(words: string[], subcommand: string): number | undefined {
  for (let index = 0; index < words.length; index += 1) {
    if (words[index] !== "git") continue
    let current = index + 1
    while (current < words.length) {
      const word = words[current] ?? ""
      if (isShellSeparator(word)) break
      if (word === subcommand) return current + 1
      if (!word.startsWith("-")) break
      if (gitGlobalOptionConsumesValue(word)) current += 1
      current += 1
    }
  }
  return undefined
}

function isArtifactPath(word: string): boolean {
  // Reject paths that semantically exclude themselves from the pathspec set.
  const magicMatch = word.match(/^:\(([^)]*)\)/)
  if (magicMatch) {
    const magic = magicMatch[1] ?? ""
    if (magic.split(",").some((entry) => entry.trim() === "exclude")) return false
  }
  const stripped = word.replace(/^:\([^)]*\)/, "").replace(/^:\//, "").replace(/^\.\/+/, "")
  if (stripped.startsWith("/")) {
    // Absolute paths bypass repo-relative matching. Treat the artifact
    // directories as path segments anywhere on the absolute path.
    return /\/docs\/(plans|superpowers)(\/|$)/.test(stripped)
  }
  return stripped === "docs/plans" || stripped === "docs/superpowers" || stripped.startsWith("docs/plans/") || stripped.startsWith("docs/superpowers/")
}

function isBroadAddPathspec(word: string): boolean {
  return word === "-A" || word === "--all" || word === "." || word === "./" || word === ":/"
}

function isShellSeparator(word: string): boolean {
  return word === ";" || word === "|" || word === "&"
}

// A commit option "consumes" the next token as its value only when the value
// is required to live in a separate token. Fused short-options like `-mMSG`
// carry the value inline and must NOT skip the next token, otherwise an
// artifact pathspec right after the message would slip through (see the
// regression tests for `git commit -m"msg" docs/plans/x.md`). A combined
// short-options run that ends in `m` with nothing after (e.g. `-am`, `-Sm`)
// still needs to consume the next token for the message.
function commitOptionConsumesValue(word: string): boolean {
  if (commitOptionsWithValues.has(word)) return true
  return /^-[^-]+m$/.test(word)
}

function gitGlobalOptionConsumesValue(word: string): boolean {
  if (word === "-C" || word === "-c" || word === "--git-dir" || word === "--work-tree" || word === "--namespace") return true
  return false
}

function hasShortOption(word: string, option: string): boolean {
  return word.startsWith("-") && !word.startsWith("--") && word.slice(1).includes(option)
}

function isProseLine(trimmed: string): boolean {
  if (!trimmed) return false
  if (/^#/.test(trimmed)) return false
  if (/^>/.test(trimmed)) return false
  if (/^[-*+]\s/.test(trimmed)) return false
  if (/^[0-9]+[.)]\s/.test(trimmed)) return false
  if (/^\|/.test(trimmed)) return false
  if (/^[-=_]+\s*$/.test(trimmed)) return false
  if (/^</.test(trimmed)) return false
  if (/^\[/.test(trimmed)) return false
  return true
}

// `git status --porcelain` and `git diff --cached --name-only` always emit
// repository-relative paths regardless of which subdirectory the shell sits
// in, so the `^docs/(plans|superpowers)/` anchor below is safe.
export async function gitHasPendingArtifacts($: Shell): Promise<boolean> {
  const result = await $`git status --porcelain -- docs/plans docs/superpowers`.quiet().nothrow()
  if ((result as ShellResult).exitCode !== 0) return false
  return String((result as ShellResult).stdout ?? "").trim().length > 0
}

export async function gitHasStagedArtifacts($: Shell): Promise<boolean> {
  const result = await $`git diff --cached --name-only`.quiet().nothrow()
  if ((result as ShellResult).exitCode !== 0) return false
  return String((result as ShellResult).stdout ?? "").split(/\r?\n/).some((line) => /^docs\/(plans|superpowers)\//.test(line))
}

export async function headIncludesArtifacts($: Shell): Promise<boolean> {
  const result = await $`git show --name-only --format= HEAD`.quiet().nothrow()
  if ((result as ShellResult).exitCode !== 0) return false
  return String((result as ShellResult).stdout ?? "").split(/\r?\n/).some((line) => /^docs\/(plans|superpowers)\//.test(line))
}

export const WorkflowGuardsPlugin: Plugin = async ({ $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      const tool = String(input.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const command = getShellCommand(output.args)
      if (!command) return

      if (matchesGitAddArtifactCommand(command)) {
        throw new Error("Workflow guard: refusing to stage agent artifacts under docs/plans or docs/superpowers. Stage explicit non-artifact paths instead.")
      }

      if (matchesBroadGitAddCommand(command) && (await safePredicate(() => gitHasPendingArtifacts($)))) {
        throw new Error("Workflow guard: refusing broad git add because docs/plans or docs/superpowers has pending changes. Stage explicit non-artifact paths instead.")
      }

      if (matchesGitCommitCommand(command)) {
        if (matchesGitCommitArtifactCommand(command)) {
          throw new Error("Workflow guard: refusing commit because the command includes docs/plans or docs/superpowers agent artifacts.")
        }
        if (matchesGitCommitAllCommand(command) && (await safePredicate(() => gitHasPendingArtifacts($)))) {
          throw new Error("Workflow guard: refusing git commit -a/--all because docs/plans or docs/superpowers has pending changes. Stage explicit non-artifact paths instead.")
        }
        if (await safePredicate(() => gitHasStagedArtifacts($))) {
          throw new Error("Workflow guard: refusing commit because staged files include docs/plans or docs/superpowers agent artifacts.")
        }
      }

      if (matchesGithubCurlCommand(command)) {
        throw new Error("Workflow guard: use gh api or another gh subcommand instead of curl for GitHub requests.")
      }
    },

    "tool.execute.after": async (input) => {
      const tool = String(input.tool ?? "").toLowerCase()

      if ((tool === "bash" || tool === "shell") && matchesGitCommitCommand(getShellCommand(input.args) ?? "")) {
        if (await safePredicate(() => headIncludesArtifacts($))) {
          console.warn("[workflow-guards] WARNING: HEAD includes docs/plans or docs/superpowers artifacts. Remove them before pushing.")
        }
      }

      for (const editedFilePath of extractEditedFilePaths(tool, input.args)) {
        if (!existsSync(editedFilePath)) continue
        try {
          const report = detectHardWrappedMarkdown(readFileSync(editedFilePath, "utf8"))
          if (report) {
            console.warn(`[workflow-guards] Markdown style: ${editedFilePath} looks hard-wrapped near line ${report.firstLine}. Re-edit prose so each paragraph is one physical line.`)
          }
        } catch {
          // Read failures shouldn't break the agent flow; skip this path.
        }
      }
    },
  }
}

// Fail-soft wrapper for async git inspections. Returns false when the
// underlying command throws or shells out outside a git repo, so a missing
// repo never escalates into a workflow-guard denial.
async function safePredicate(predicate: () => Promise<boolean>): Promise<boolean> {
  try {
    return await predicate()
  } catch {
    return false
  }
}

export default WorkflowGuardsPlugin
