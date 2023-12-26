local M = {}
local data = {}
local Path = require('plenary.path')
local autogroup = vim.api.nvim_create_augroup("DEBUG_SELECT", { clear = true })
local data_path = Path:new(vim.fn.stdpath("data") .. Path.path.sep .. "debug-select.json")
local config = {
    width = 60,
    height = 10,
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    save_on_change = true,
    dap_continue_on_select = false,
    git_worktree_integration = false
}

local function read_data() 
    if data_path:exists() then
        data = vim.fn.json_decode(data_path:read())
    end
end

local function save_data() 
    data_path:write(vim.fn.json_encode(data), "w")
end

local function get_values(key)
    local cwd = vim.fn.getcwd()
    local data_cwd = data[cwd]
    if data_cwd then
        ret = data[cwd][key]
        if ret then
            return ret
        end
    end
    return {}
end

local function set_values(key, values)
    if config.save_on_change then
        read_data()
    end
    local cwd = vim.fn.getcwd()
    local data_cwd = data[cwd]
    if not data_cwd then
        data[cwd] = {}
    end 
    data[cwd][key] = values 
    if config.save_on_change then
        save_data()
    end
end

function M.setup(_config)
    config = vim.tbl_deep_extend("force",config, _config or {})

    if config.git_worktree_integration == true then
        local Worktree = require('git-worktree')
        Worktree.on_tree_change(function(op, metadata)
            if op == Worktree.Operations.Create then
                if config.save_on_change then
                    read_data()
                end
                local data_cwd = data[vim.fn.getcwd()]
                local path = Path:new(metadata.path)
                if data_cwd then
                    data[path:absolute()] = data_cwd
                    if config.save_on_change then
                        save_data()
                    end
                end
            end
        end)
    end

    if config.save_on_change == false then
        vim.api.nvim_create_autocmd("VimLeave", {
            callback = function()
                local cwd = vim.fn.getcwd()
                local data_cwd = data[cwd]
                if data_cwd then
                    read_data()
                    data[cwd] = data_cwd
                    save_data()
                end
            end,
            group = autogroup 
        })
    end
end

function M.get_config()
    return config
end

function M.get_autogroup()
    return autogroup
end

function M.set_programs(programs)
    set_values("programs", programs)
end

function M.get_programs() 
    return get_values("programs")
end

function M.set_args(args)
    set_values("args", args)
end

function M.get_args()
    return get_values("args", args)
end

read_data()
return M
