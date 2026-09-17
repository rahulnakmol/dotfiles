local function project_root()
  return LazyVim.root.get()
end

local function prompt(label, callback)
  vim.ui.input({ prompt = label }, function(value)
    if value and value ~= "" then
      callback(value)
    end
  end)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>Br",
        function()
          Snacks.terminal({ "bun", vim.api.nvim_buf_get_name(0) }, { cwd = project_root() })
        end,
        desc = "Bun: Run Current File",
      },
      {
        "<leader>Bt",
        function()
          Snacks.terminal({ "bun", "test" }, { cwd = project_root() })
        end,
        desc = "Bun: Test Project",
      },
      {
        "<leader>BT",
        function()
          Snacks.terminal({ "bun", "test", vim.api.nvim_buf_get_name(0) }, { cwd = project_root() })
        end,
        desc = "Bun: Test Current File",
      },
      {
        "<leader>Bs",
        function()
          prompt("bun run ", function(script)
            Snacks.terminal({ "bun", "run", script }, { cwd = project_root() })
          end)
        end,
        desc = "Bun: Run Script",
      },
      {
        "<leader>Bf",
        function()
          prompt("Workspace filter: ", function(filter)
            prompt("Script: ", function(script)
              Snacks.terminal({ "bun", "run", "--filter", filter, script }, { cwd = project_root() })
            end)
          end)
        end,
        desc = "Bun: Run Workspace Script",
      },
      {
        "<leader>Bu",
        function()
          prompt("turbo run ", function(task)
            Snacks.terminal({ "bunx", "turbo", "run", task }, { cwd = project_root() })
          end)
        end,
        desc = "Bun: Run Turbo Task",
      },
    },
  },
}
