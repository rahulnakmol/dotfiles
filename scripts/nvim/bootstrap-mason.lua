local packages = {
  "codelldb",
  "csharpier",
  "delve",
  "docker-compose-language-service",
  "dockerfile-language-server",
  "fantomas",
  "fsautocomplete",
  "gofumpt",
  "goimports",
  "golangci-lint",
  "gopls",
  "hadolint",
  "helm-ls",
  "js-debug-adapter",
  "json-lsp",
  "markdown-toc",
  "markdownlint-cli2",
  "marksman",
  "netcoredbg",
  "omnisharp",
  "prettier",
  "pyright",
  "ruff",
  "shellcheck",
  "shfmt",
  "sqlfluff",
  "stylua",
  "taplo",
  "tailwindcss-language-server",
  "terraform-ls",
  "tflint",
  "vtsls",
  "yaml-language-server",
}

local function fail(message)
  vim.api.nvim_err_writeln("Mason bootstrap failed: " .. message)
  vim.cmd("cquit 1")
end

local ok, err = pcall(function()
  require("lazy").load({ plugins = { "mason.nvim" } })
  local registry = require("mason-registry")

  registry.refresh()

  local targets = {}
  for _, name in ipairs(packages) do
    local found, package = pcall(registry.get_package, name)
    if not found then
      error("unknown package: " .. name)
    end
    targets[#targets + 1] = package
  end

  local settled = vim.wait(600000, function()
    for _, package in ipairs(targets) do
      if package:is_installing() then
        return false
      end
    end
    return true
  end, 100)
  if not settled then
    error("timed out waiting for in-flight installations")
  end

  local missing = {}
  for _, package in ipairs(targets) do
    if not package:is_installed() then
      missing[#missing + 1] = package.name
    end
  end
  if #missing > 0 then
    vim.api.nvim_cmd({ cmd = "MasonInstall", args = missing }, {})
  end

  local unresolved = {}
  for _, package in ipairs(targets) do
    if not package:is_installed() then
      unresolved[#unresolved + 1] = package.name
    end
  end
  if #unresolved > 0 then
    error("packages still missing: " .. table.concat(unresolved, ", "))
  end
end)

if not ok then
  fail(tostring(err))
end

print("Mason packages verified")
