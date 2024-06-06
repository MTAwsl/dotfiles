-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require('dap-python').setup('~/.virtualenvs/global/bin/python')
        end,
    },
    {
        "loctvl842/monokai-pro.nvim",
        config = function()
            require("monokai-pro").setup({
              transparent_background = false,
              terminal_colors = true,
              devicons = true, -- highlight the icons of `nvim-web-devicons`
              styles = {
                comment = { italic = true },
                keyword = { italic = true }, -- any other keyword
                type = { italic = true }, -- (preferred) int, long, char, etc
                storageclass = { italic = true }, -- static, register, volatile, etc
                structure = { italic = true }, -- struct, union, enum, etc
                parameter = { italic = true }, -- parameter pass in function
                annotation = { italic = true },
                tag_attribute = { italic = true }, -- attribute of tag in reactjs
              },
              filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
              -- Enable this will disable filter option
              day_night = {
                enable = false, -- turn off by default
                day_filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
                night_filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
              },
              inc_search = "background", -- underline | background
              background_clear = {
                -- "float_win",
                "toggleterm",
                "telescope",
                -- "which-key",
                "renamer",
                "notify",
                -- "nvim-tree",
                -- "neo-tree",
                -- "bufferline", -- better used if background of `neo-tree` or `nvim-tree` is cleared
              },-- "float_win", "toggleterm", "telescope", "which-key", "renamer", "neo-tree", "nvim-tree", "bufferline"
              plugins = {
                bufferline = {
                  underline_selected = false,
                  underline_visible = false,
                },
                indent_blankline = {
                  context_highlight = "default", -- default | pro
                  context_start_underline = false,
                },
              },
            })
        end,
    }
}

lvim.autocommands = {
    {
        { "ColorScheme" },
        {
            pattern = "*",
            callback = function()
                vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = "#7aa2f7" })
                vim.api.nvim_set_hl(0, "DapStoppedLinehl", { bg = "#555530" })

                vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg='#993939' })
                vim.api.nvim_set_hl(0, 'DapLogPoint', { fg='#98c379' })
                vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg='#efaf61' })

                lvim.builtin.dap.breakpoint = { text = lvim.icons.ui.Circle, texthl = "DapBreakpoint", linehl = "", numhl = "" }
                lvim.builtin.dap.breakpoint_rejected = { text = lvim.icons.diagnostics.BoldError, texthl = "Error", linehl = "", numhl = "" }
                lvim.builtin.dap.stopped = { text = lvim.icons.ui.BoldArrowRight, texthl = "Error", linehl = "DapStoppedLinehl", numhl = "" }
                vim.fn.sign_define("DapBreakpointCondition", { text = lvim.icons.ui.Circle, texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
                vim.fn.sign_define("DapLogPoint", { text = lvim.icons.ui.Circle, texthl = "DapLogPoint", linehl = "", numhl = "" })
            end,
        },
    },
}

vim.opt.number = true
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4

-- Color scheme
lvim.colorscheme = "monokai-pro"

-- Clear search buffer
lvim.keys.normal_mode['<CR>'] = "<Cmd>noh<CR><CR>"

-- DAP configs

lvim.keys.normal_mode['<F2>'] = "<Cmd>lua require'dap'.toggle_breakpoint()<CR>"
lvim.keys.normal_mode['<F7>'] = "<Cmd>lua require'dap'.step_into()<CR>"
lvim.keys.normal_mode['<F8>'] = "<Cmd>lua require'dap'.step_over()<CR>"
lvim.keys.normal_mode['<F9>'] = "<Cmd>lua require'dap'.continue()<CR>"
lvim.keys.normal_mode['<F10>'] = "<Cmd>lua require'dap'.step_out()<CR>"
lvim.keys.normal_mode['<F12>'] = "<Cmd>lua require'dap'.terminate()<CR>"

-- Press kj to exit to normal mode
lvim.keys.insert_mode['kj'] = "<ESC>"

lvim.builtin.which_key.mappings['dn'] = {"<Cmd>lua require('dap-python').test_method()<CR>", "Debug Python Method"}
lvim.builtin.which_key.mappings['df'] = {"<Cmd>lua require('dap-python').test_class()<CR>", "Debug Python Class"}
lvim.builtin.which_key.vmappings['d'] = {
    name = "Debug",
    s = {"<ESC><Cmd>lua require('dap-python').debug_selection()<CR>", "Debug Selected Python Code"}
}
lvim.builtin.which_key.mappings['bc'] = {"<Cmd>bd<CR>", "Close Current Buffer"}

local dap, dapui = require("dap"), require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

lvim.builtin.indentlines.active = false
lvim.builtin.treesitter.highlight = {enable = true, additional_vim_regex_highlighting = {"python"}}
