maki.setup({
    ui = {
        splash_animation = false,
        typewriter_ms_per_char = 0,
        mouse_scroll_lines = 5,
        flash_duration_ms = 3000,
        tool_output_lines = {
            bash = 1,
            code_execution = 1,
            task = 1,
            index = 1,
            grep = 1,
            read = 1,
            write = 1,
            web = 1,
            other = 1,
        },
    },
    agent = {
        compaction_buffer = 10000,
    },
})
