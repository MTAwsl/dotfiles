-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

lvim.plugins = {
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require('dap-python').setup('~/.virtualenvs/global/bin/python')
        end,
    },
    {
        "lervag/vimtex",
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install",
        init = function()
          vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
       'adelarsq/image_preview.nvim',
        event = 'VeryLazy',
        config = function()
            require("image_preview").setup()
        end
    },
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

-- Clear search buffer
lvim.keys.normal_mode['<CR>'] = "<Cmd>noh<CR><CR>"

-- Press kj to exit insert more.
lvim.keys.insert_mode['kj'] = "<Esc>"

-- DAP configs

lvim.keys.normal_mode['<F2>'] = "<Cmd>lua require'dap'.toggle_breakpoint()<CR>"
lvim.keys.normal_mode['<F7>'] = "<Cmd>lua require'dap'.step_into()<CR>"
lvim.keys.normal_mode['<F8>'] = "<Cmd>lua require'dap'.step_over()<CR>"
lvim.keys.normal_mode['<F9>'] = "<Cmd>lua require'dap'.continue()<CR>"
lvim.keys.normal_mode['<F10>'] = "<Cmd>lua require'dap'.step_out()<CR>"
lvim.keys.normal_mode['<F12>'] = "<Cmd>lua require'dap'.terminate()<CR>"

lvim.builtin.which_key.mappings['dn'] = {"<Cmd>lua require('dap-python').test_method()<CR>", "Debug Python Method"}
lvim.builtin.which_key.mappings['df'] = {"<Cmd>lua require('dap-python').test_class()<CR>", "Debug Python Class"}
lvim.builtin.which_key.vmappings['d'] = {
    name = "Debug",
    s = {"<ESC><Cmd>lua require('dap-python').debug_selection()<CR>", "Debug Selected Python Code"}
}
lvim.builtin.which_key.mappings['m'] = {
    name = "MarkdownPreview",
    s = { "<Cmd>MarkdownPreview<CR>", "MarkdownPreview"},
    x = { "<Cmd>MarkdownPreviewStop<CR>", "MarkdownPreviewStop"},
    t = { "<Cmd>MarkdownPreviewToggle<CR>", "MarkdownPreviewToggle"}
}

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
lvim.builtin.treesitter.highlight = {
    enable = true,
    disable = {
        "latex"
    },
    additional_vim_regex_highlighting = {"python"}
}

package.path = package.path .. ";/Users/socular/.config/lvim/?.lua"
require("markdown-config")
