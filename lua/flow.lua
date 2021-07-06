local DiagnosticSeverity = vim.lsp.protocol.DiagnosticSeverity

local M = {}
local MESSAGE = "Uncovered code"
local COVERAGE_CLIENT_ID = 1004

local function convert_coverage_to_diagnostics(coverage)
  local diagnostics = coverage.uncoveredRanges
  for _, diag in ipairs(diagnostics) do
    diag.message = MESSAGE
    diag.severity = DiagnosticSeverity.Warning
  end
  return diagnostics
end

vim.lsp.handlers["textDocument/typeCoverage"] = function(err, _, params, _, bufnr)
  if err ~= nil then
    error(err)
    return
  end

  local type_diagnostics = convert_coverage_to_diagnostics(params)
  -- We're using a fake client ID here so the coverage diagnostics don't collide
  -- with the normal diagnostics
  vim.lsp.diagnostic.save(type_diagnostics, bufnr, COVERAGE_CLIENT_ID)
  vim.lsp.diagnostic.display(type_diagnostics, bufnr, COVERAGE_CLIENT_ID)
  vim.api.nvim_buf_set_var(bufnr, "flow_coverage_percent", params.coveredPercent)
end

M.on_attach = function(_)
  vim.cmd([[
  aug FlowCoverage
    au!
    autocmd User LspDiagnosticsChanged lua require'flow'.check_coverage()
  aug END
  ]])
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
