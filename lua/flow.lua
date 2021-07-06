local protocol = require("vim.lsp.protocol")
local DiagnosticSeverity = protocol.DiagnosticSeverity

local M = {}

M._convert_coverage_to_diagnostics = function(coverage)
  local diagnostics = coverage.uncoveredRanges
  for _, diag in ipairs(diagnostics) do
    diag.message = "Uncovered code"
    diag.severity = DiagnosticSeverity.Warning
  end
  return diagnostics
end

M._handle_coverage = function(err, _, params, client_id, bufnr)
  if err ~= nil then
    error(err)
    return
  end
  local diagnostics = M._convert_coverage_to_diagnostics(params)
  vim.lsp.diagnostic.set_signs(diagnostics, bufnr, client_id, nil, { priority = 8 })
  vim.lsp.diagnostic.set_underline(diagnostics, bufnr, client_id, nil, nil)

  vim.api.nvim_buf_set_var(bufnr, "flow_coverage_percent", params.coveredPercent)
end

M.on_attach = function(_)
  vim.lsp.handlers["textDocument/typeCoverage"] = M._handle_coverage
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
  vim.lsp.buf_request(bufnr, "textDocument/typeCoverage", params)
end

M.get_coverage_percent = function(bufnr)
  local status, coverage = pcall(vim.api.nvim_buf_get_var, bufnr, "flow_coverage_percent")
  if not status then
    return nil
  end
  return coverage
end

return M
