local Path = require('plenary.path')
local debug_select = require('debug-select') 
local M = require('debug-select.base'):new()

M.title = "DebugSelect Program"
M.bufname = "debug-select-program-menu"
M.set_values = debug_select.set_programs
M.get_values = debug_select.get_programs

function M.get_program()
    local value = debug_select.get_programs()[1]
    if value then
        local path = Path:new(value) 
        if path:exists() then
            return path:absolute()
        end
    end
    return value 
end

return M
