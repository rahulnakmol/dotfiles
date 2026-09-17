local function fail(message)
  vim.api.nvim_err_writeln("Tree-sitter bootstrap failed: " .. message)
  vim.cmd("cquit 1")
end

local ok, err = pcall(function()
  require("lazy").load({ plugins = { "nvim-treesitter" } })

  local treesitter = require("nvim-treesitter")
  local configured = LazyVim.opts("nvim-treesitter").ensure_installed or {}
  local installed = {}

  for _, parser in ipairs(treesitter.get_installed("parsers")) do
    installed[parser] = true
  end

  local missing = {}
  for _, parser in ipairs(configured) do
    if not installed[parser] then
      missing[#missing + 1] = parser
    end
  end

  if #missing > 0 then
    local task = treesitter.install(missing, { summary = true })
    local task_ok, success = task:pwait(600000)
    if not task_ok or not success then
      error("one or more parser installations failed")
    end
  end

  installed = {}
  for _, parser in ipairs(treesitter.get_installed("parsers")) do
    installed[parser] = true
  end

  local unresolved = {}
  for _, parser in ipairs(configured) do
    if not installed[parser] then
      unresolved[#unresolved + 1] = parser
    end
  end
  if #unresolved > 0 then
    table.sort(unresolved)
    error("parsers still missing: " .. table.concat(unresolved, ", "))
  end
end)

if not ok then
  fail(tostring(err))
end

print("Tree-sitter parsers verified")
