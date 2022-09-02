local M = {}
local popup = require('plenary.popup')
local debug_select = require('debug-select')
local config = debug_select.get_config

function M:get_items()
    local indices = {}
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true)
    for i = 1, #lines do
        if lines[i]:gsub("%s", "") ~= "" then
            table.insert(indices, lines[i])
        end
    end
    return indices
end

function M:select_current_item()
    local idx = vim.fn.line('.')
    local values = self:get_items()
    if idx > #values then
        idx = #values
    end
    table.insert(values, 1, values[idx])
    table.remove(values, idx + 1)
    self.set_values(values)
    vim.api.nvim_win_close(self.win_id, true)

    if config().dap_continue_on_select == true then
        require('dap').continue()
    end
end

function M:toggle_menu()
   if self.bufnr and self.win_id then
        local values = self:get_items()
        self.set_values(values)
        vim.api.nvim_win_close(self.win_id, true)
    else
        local win
        self.bufnr = vim.api.nvim_create_buf(false, false)
        self.win_id, win = popup.create(self.bufnr, {
            title = self.title,
            highlight = "DebugSelectWindow",
            line = math.floor(((vim.o.lines - config().height) / 2) - 1),
            col = math.floor((vim.o.columns - config().width) / 2),
            minwidth = config().width,
            minheight = config().height,
            borderchars = config().borderchars,
        })
        vim.api.nvim_win_set_option(
            win.border.win_id,
            "winhl",
            "Normal:DebugSelectBorder"
        )

        local values = self.get_values()
        vim.api.nvim_buf_set_lines(self.bufnr, 0, #values, false, values)
        vim.api.nvim_win_set_option(self.win_id, "number", true)
        vim.api.nvim_buf_set_name(self.bufnr, self.bufname)
        vim.api.nvim_buf_set_option(self.bufnr, "filetype", "debug-select")
        vim.api.nvim_buf_set_option(self.bufnr, "buftype", "acwrite")
        vim.api.nvim_buf_set_option(self.bufnr, "bufhidden", "delete")

        vim.keymap.set("n", "q", function()
                self:toggle_menu()
        end, {
            silent = true,
            buffer = self.bufnr
        })
        vim.keymap.set("n", "<ESC>", function()
                self:toggle_menu()
        end, {
            silent = true,
            buffer = self.bufnr
        })
        vim.keymap.set("n", "<CR>", function()
                self:select_current_item()
        end, {
            silent = true,
            buffer = self.bufnr
        })

        vim.api.nvim_create_autocmd("BufWriteCmd", {
            callback = function()
                local values = self:get_items()
                self.set_values(values)
            end,
            buffer = self.bufnr,
            group = debug_select.get_autogroup(),
        })
        vim.api.nvim_create_autocmd("BufUnload", {
            callback = function()
                self.win_id = nil
                self.bufnr = nil
            end,
            buffer = self.bufnr,
            group = debug_select.get_autogroup(),
        })
    end
end

function M:new()
    local newObj = {}
    self.__index = self
    return setmetatable(newObj, self)
end

return M
