/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginApi, TuiPluginModule } from "@opencode-ai/plugin/tui"
import { Show } from "solid-js"

const id = "noah.branch-indicator"

function View(props: { api: TuiPluginApi }) {
  const theme = () => props.api.theme.current
  const branch = () => props.api.state.vcs?.branch
  return (
    <Show when={branch()}>
      <text fg={theme().textMuted}>⎇ {branch()}</text>
    </Show>
  )
}

const tui: TuiPlugin = async (api) => {
  api.slots.register({
    slots: {
      session_prompt_right() {
        return <View api={api} />
      },
    },
  })
}

const plugin: TuiPluginModule = {
  id,
  tui,
}

export default plugin
