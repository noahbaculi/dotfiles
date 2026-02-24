return {
  "pteroctopus/faster.nvim",
  event = "VeryLazy",
  opts = {
    behaviours = {
      bigfile = {
        -- Files larger than `filesize` are considered big files. Value is in MB.
        filesize = 1,
      },
    },
  },
}
