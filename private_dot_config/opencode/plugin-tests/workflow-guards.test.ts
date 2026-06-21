import { $ } from "bun"
import { describe, expect, test } from "bun:test"
import { mkdtempSync, mkdirSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"
import {
  detectHardWrappedMarkdown,
  extractEditedFilePaths,
  getShellCommand,
  gitHasPendingArtifacts,
  gitHasStagedArtifacts,
  headIncludesArtifacts,
  matchesBroadGitAddCommand,
  matchesGitAddArtifactCommand,
  matchesGitCommitAllCommand,
  matchesGitCommitArtifactCommand,
  matchesGitCommitCommand,
  matchesGithubCurlCommand,
} from "../plugins/workflow-guards"

describe("workflow guard command matching", () => {
  test("extracts bash commands", () => {
    expect(getShellCommand({ command: "git status" })).toBe("git status")
    expect(getShellCommand({ command: "" })).toBeUndefined()
    expect(getShellCommand({})).toBeUndefined()
  })

  test("matches explicit artifact staging", () => {
    expect(matchesGitAddArtifactCommand("git -C . add docs/superpowers")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add docs/superpowers")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add docs/plans")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add docs/superpowers/spec.md")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add docs/plans/plan.md")).toBe(true)
    expect(matchesGitAddArtifactCommand('git add "docs/superpowers/spec.md"')).toBe(true)
    expect(matchesGitAddArtifactCommand("git add ./docs/plans/plan.md")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add src/lib.rs")).toBe(false)
  })

  test("matches absolute artifact paths", () => {
    // Regression for review issue 5: agents could bypass the guard by passing
    // an absolute path to the same file.
    expect(matchesGitAddArtifactCommand("git add /Users/x/repo/docs/plans/plan.md")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add /Users/x/repo/docs/superpowers/spec.md")).toBe(true)
    expect(matchesGitAddArtifactCommand("git add /Users/x/repo/src/lib.rs")).toBe(false)
  })

  test("respects :(exclude) pathspec magic", () => {
    // Regression for review issue 5: :(exclude)docs/plans/x.md tells git to
    // EXCLUDE that path, so the guard must not deny it.
    expect(matchesGitAddArtifactCommand("git add :(exclude)docs/plans/plan.md")).toBe(false)
    expect(matchesGitAddArtifactCommand("git add ':(exclude,glob)docs/plans/*.md'")).toBe(false)
    // :(top) is a legitimate way to refer to repo-root-relative paths.
    expect(matchesGitAddArtifactCommand("git add ':(top)docs/plans/plan.md'")).toBe(true)
  })

  test("matches broad git add commands", () => {
    expect(matchesBroadGitAddCommand('git -C . add "."')).toBe(true)
    expect(matchesBroadGitAddCommand("git add -A")).toBe(true)
    expect(matchesBroadGitAddCommand("git add --all")).toBe(true)
    expect(matchesBroadGitAddCommand("git add .")).toBe(true)
    expect(matchesBroadGitAddCommand('git add "."')).toBe(true)
    expect(matchesBroadGitAddCommand("git add ./")).toBe(true)
    expect(matchesBroadGitAddCommand("git add :/")).toBe(true)
    expect(matchesBroadGitAddCommand("git add src/lib.rs")).toBe(false)
  })

  test("matches git commit commands", () => {
    expect(matchesGitCommitCommand("git -C . commit -m test")).toBe(true)
    expect(matchesGitCommitCommand("git commit -m test")).toBe(true)
    expect(matchesGitCommitCommand("git status")).toBe(false)
  })

  test("matches commit commands that stage tracked files", () => {
    expect(matchesGitCommitAllCommand("git -C . commit -am test")).toBe(true)
    expect(matchesGitCommitAllCommand("git commit -S -am test")).toBe(true)
    expect(matchesGitCommitAllCommand("git commit -am test")).toBe(true)
    expect(matchesGitCommitAllCommand("git commit --all -m test")).toBe(true)
    expect(matchesGitCommitAllCommand("git commit --amend -m test")).toBe(false)
    expect(matchesGitCommitAllCommand("git commit -m test")).toBe(false)
  })

  test("matches artifact pathspec commits", () => {
    expect(matchesGitCommitArtifactCommand("git -C . commit docs/superpowers/spec.md -m test")).toBe(true)
    expect(matchesGitCommitArtifactCommand("git commit -S docs/superpowers/spec.md -m test")).toBe(true)
    expect(matchesGitCommitArtifactCommand("git commit docs/superpowers/spec.md -m test")).toBe(true)
    expect(matchesGitCommitArtifactCommand('git commit "./docs/plans/plan.md" -m test')).toBe(true)
    expect(matchesGitCommitArtifactCommand("git commit :/docs/superpowers/spec.md -m test")).toBe(true)
    expect(matchesGitCommitArtifactCommand("git commit ':(top)docs/superpowers/spec.md' -m test")).toBe(true)
    expect(matchesGitCommitArtifactCommand('git commit -m "docs/superpowers is mentioned"')).toBe(false)
    expect(matchesGitCommitArtifactCommand("git commit -S -m test")).toBe(false)
    expect(matchesGitCommitArtifactCommand("git commit src/lib.rs -m test")).toBe(false)
  })

  test("blocks artifact pathspecs hidden behind fused -mMSG", () => {
    // Regression for review issue 1: the previous commitOptionConsumesValue
    // treated -mMSG as a flag that consumes the next token, skipping right
    // over the artifact pathspec.
    expect(matchesGitCommitArtifactCommand('git commit -m"msg" docs/plans/plan.md')).toBe(true)
    expect(matchesGitCommitArtifactCommand('git commit -m"feat: x" docs/superpowers/spec.md')).toBe(true)
    // Combined short option that still needs a separate value must keep
    // consuming the next token so the value is not parsed as a pathspec.
    expect(matchesGitCommitArtifactCommand("git commit -Sm msg src/lib.rs")).toBe(false)
    expect(matchesGitCommitArtifactCommand("git commit -Sm msg docs/plans/plan.md")).toBe(true)
  })

  test("matches curl to github", () => {
    expect(matchesGithubCurlCommand("curl github.com/owner/repo")).toBe(true)
    expect(matchesGithubCurlCommand("curl https://github.com/owner/repo")).toBe(true)
    expect(matchesGithubCurlCommand("curl https://api.github.com/repos/owner/repo")).toBe(true)
    expect(matchesGithubCurlCommand('curl "https://api.github.com/repos/owner/repo"')).toBe(true)
    expect(matchesGithubCurlCommand("curl https://example.com")).toBe(false)
  })
})

describe("workflow guard edit detection", () => {
  test("extracts edited markdown paths", () => {
    expect(extractEditedFilePaths("edit", { filePath: "/tmp/a.md" })).toEqual(["/tmp/a.md"])
    expect(extractEditedFilePaths("write", { file_path: "/tmp/a.markdown" })).toEqual(["/tmp/a.markdown"])
    expect(extractEditedFilePaths("apply_patch", { patchText: "*** Add File: docs/a.md\n" })).toEqual(["docs/a.md"])
    expect(extractEditedFilePaths("read", { filePath: "/tmp/a.md" })).toEqual([])
    expect(extractEditedFilePaths("edit", { filePath: "/tmp/a.rs" })).toEqual([])
  })

  test("returns every markdown file in a multi-file patch", () => {
    // Regression for review issue 6: previously only the first patch header
    // was inspected, so an apply_patch that touched src/lib.rs first and
    // README.md second silently skipped the markdown wrap check.
    const patchText = "*** Update File: src/lib.rs\n@@\n-foo\n+bar\n*** Add File: docs/note.md\n+content\n*** Update File: README.md\n+more\n"
    expect(extractEditedFilePaths("apply_patch", { patchText })).toEqual(["docs/note.md", "README.md"])
  })

  test("includes Move to targets when they are markdown", () => {
    const patchText = "*** Update File: src/a.rs\n*** Move to: docs/renamed.md\n"
    expect(extractEditedFilePaths("apply_patch", { patchText })).toEqual(["docs/renamed.md"])
  })

  test("detects hard-wrapped markdown prose", () => {
    const markdown = "This is a prose paragraph that is deliberately long enough to look like a hard wrapped line ending mid sentence\nand this continuation line makes the detector report a wrapped paragraph.\n"
    expect(detectHardWrappedMarkdown(markdown)).toEqual({ count: 1, firstLine: 1 })
  })

  test("ignores lists, headings, and code fences", () => {
    const markdown = "# Heading\n\n- This is a very long list item that should not count because list items are excluded from prose wrapping checks\n- This continuation is still a list item\n\n```text\nThis is a long line inside a fence that should not trigger the prose detector even when it wraps\ncontinued line\n```\n"
    expect(detectHardWrappedMarkdown(markdown)).toBeUndefined()
  })
})

describe("workflow guard git predicates", () => {
  // Fixture tests covering review issue 8: previously these helpers had no
  // coverage, so the fail-soft contract (return false on any git error) was
  // not protected against regressions.
  async function makeRepo(): Promise<string> {
    const dir = mkdtempSync(join(tmpdir(), "workflow-guards-"))
    await $`git init -q`.cwd(dir).quiet()
    await $`git config user.email t@t`.cwd(dir).quiet()
    await $`git config user.name t`.cwd(dir).quiet()
    await $`git config commit.gpgsign false`.cwd(dir).quiet()
    return dir
  }

  test("gitHasPendingArtifacts reports false on a clean repo", async () => {
    const dir = await makeRepo()
    expect(await gitHasPendingArtifacts($.cwd(dir))).toBe(false)
  })

  test("gitHasPendingArtifacts detects untracked artifacts", async () => {
    const dir = await makeRepo()
    mkdirSync(join(dir, "docs/plans"), { recursive: true })
    writeFileSync(join(dir, "docs/plans/plan.md"), "x")
    expect(await gitHasPendingArtifacts($.cwd(dir))).toBe(true)
  })

  test("gitHasPendingArtifacts returns false outside a repo", async () => {
    const dir = mkdtempSync(join(tmpdir(), "workflow-guards-norepo-"))
    expect(await gitHasPendingArtifacts($.cwd(dir))).toBe(false)
  })

  test("gitHasStagedArtifacts detects staged artifacts", async () => {
    const dir = await makeRepo()
    mkdirSync(join(dir, "docs/superpowers"), { recursive: true })
    writeFileSync(join(dir, "docs/superpowers/spec.md"), "x")
    await $`git add docs/superpowers/spec.md`.cwd(dir).quiet()
    expect(await gitHasStagedArtifacts($.cwd(dir))).toBe(true)
  })

  test("gitHasStagedArtifacts ignores non-artifact staged files", async () => {
    const dir = await makeRepo()
    writeFileSync(join(dir, "README.md"), "x")
    await $`git add README.md`.cwd(dir).quiet()
    expect(await gitHasStagedArtifacts($.cwd(dir))).toBe(false)
  })

  test("headIncludesArtifacts inspects HEAD", async () => {
    const dir = await makeRepo()
    mkdirSync(join(dir, "docs/plans"), { recursive: true })
    writeFileSync(join(dir, "docs/plans/plan.md"), "x")
    await $`git add docs/plans/plan.md`.cwd(dir).quiet()
    await $`git commit -q -m wip`.cwd(dir).quiet()
    expect(await headIncludesArtifacts($.cwd(dir))).toBe(true)
  })

  test("headIncludesArtifacts returns false when HEAD is clean of artifacts", async () => {
    const dir = await makeRepo()
    writeFileSync(join(dir, "README.md"), "x")
    await $`git add README.md`.cwd(dir).quiet()
    await $`git commit -q -m initial`.cwd(dir).quiet()
    expect(await headIncludesArtifacts($.cwd(dir))).toBe(false)
  })
})
