local M = {}
local MESSAGE = "Uncovered code"
local GENERAL_DIAGNOSTICS = vim.diagnostic ~= nil
local NS = vim.api.nvim_create_namespace("FlowCoverage")

local function convert_coverage_to_diagnostics(coverage)
  if GENERAL_DIAGNOSTICS then
    local diagnostics = {}
    for _, diag in ipairs(coverage.uncoveredRanges) do
      table.insert(diagnostics, {
        message = MESSAGE,
        severity = vim.diagnostic.severity.WARN,
        lnum = diag.range.start.line,
        end_lnum = diag.range["end"].line,
        col = diag.range.start.character,
        end_col = diag.range["end"].character,
      })
    end
    return diagnostics
  else
    local diagnostics = coverage.uncoveredRanges
    for _, diag in ipairs(diagnostics) do
      diag.message = MESSAGE
      diag.severity = vim.lsp.protocol.DiagnosticSeverity.Warning
    end
    return diagnostics
  end
end

-- callback args changed in Neovim 0.6. See:
-- https://github.com/neovim/neovim/pull/15504
local function mk_handler(fn)
  return function(...)
    local config_or_client_id = select(4, ...)
    local is_new = type(config_or_client_id) ~= "number"
    if is_new then
      fn(...)
    else
      local err = select(1, ...)
      local method = select(2, ...)
      local result = select(3, ...)
      local client_id = select(4, ...)
      local bufnr = select(5, ...)
      local config = select(6, ...)
      fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, config)
    end
  end
end

vim.lsp.handlers["textDocument/typeCoverage"] = mk_handler(function(err, result, context, _config)
  if err ~= nil then
    error(err)
    return
  end
  local bufnr = context.bufnr

  local type_diagnostics = convert_coverage_to_diagnostics(result)
  if GENERAL_DIAGNOSTICS then
    print(string.format("ns: %s, buf: %s, diag: %s", NS, bufnr, vim.inspect(type_diagnostics)))
    vim.diagnostic.set(NS, bufnr, type_diagnostics)
  else
    -- We're using a fake client ID here so the coverage diagnostics don't collide
    -- with the normal diagnostics
    vim.lsp.diagnostic.save(type_diagnostics, bufnr, NS)
    vim.lsp.diagnostic.display(type_diagnostics, bufnr, NS)
  end
  vim.api.nvim_buf_set_var(bufnr, "flow_coverage_percent", result.coveredPercent)
end)

M.on_attach = function(_)
  local autocmd = GENERAL_DIAGNOSTICS and "DiagnosticsChanged" or "LspDiagnosticsChanged"
  vim.cmd(string.format(
    [[
  aug FlowCoverage
    au!
    autocmd User %s lua require'flow'.check_coverage()
  aug END
  ]],
    autocmd
  ))
  M.check_coverage()
end

M.check_coverage = function(bufnr)
  local params = {
    textDocument = {
      uri = vim.uri_from_bufnr(bufnr),
    },
  }
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    -- Would like to use supports_method here, but textDocument/typeCoverage
    -- isn't advertised properly
    if client.name == "flow" then
      client.request("textDocument/typeCoverage", params, nil, vim.api.nvim_get_current_buf())
    end
  end
end

M.get_coverage_percent = function(bufnr)
  local status, coverage = pcall(vim.api.nvim_buf_get_var, bufnr, "flow_coverage_percent")
  if not status then
    return nil
  end
  return coverage
end

return M
