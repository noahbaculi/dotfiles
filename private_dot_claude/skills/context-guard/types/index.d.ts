export type Tokens = number | null

declare module 'claude-code' {
  interface PluginState {
    'context-guard': { tokens: Tokens }
  }
}
