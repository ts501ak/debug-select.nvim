local debug_select = require('debug-select')
local M = require('debug-select.base'):new()

M.title = "DebugSelect Args"
M.bufname = "debug-select-args-menu"
M.set_values = debug_select.set_args
M.get_values = debug_select.get_args

function M.get_args()
    local value = debug_select.get_args()[1]
    if value then
        local ret = {}
        for i in string.gmatch(value, "%S+") do
            table.insert(ret, i)
        end
        return ret
    end
    return value 
end

return M
