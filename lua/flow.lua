local protocol = require('vim.lsp.protocol')
local DiagnosticSeverity = protocol.DiagnosticSeverity

local M = {}

M._convert_coverage_to_diagnostics = function(coverage)
  local diagnostics = coverage.uncoveredRanges
  for _,diag in ipairs(diagnostics) do
    diag.message = "Uncovered code"
    diag.severity = DiagnosticSeverity.Warning
  end
  return diagnostics
end

vim.lsp.handlers['textDocument/typeCoverage'] = function(err, _method, params, client_id, bufnr)
  if err ~= nil then
    error(err)
    return
  end
  local mode = vim.api.nvim_get_mode()
  if string.sub(mode.mode, 1, 1) == 'i' then return end

  diagnostics = M._convert_coverage_to_diagnostics(params)
  vim.lsp.diagnostic.set_signs(diagnostics, bufnr, client_id, nil, nil)
  vim.lsp.diagnostic.set_underline(diagnostics, bufnr, client_id, nil, nil)

  vim.api.nvim_buf_set_var(bufnr, 'flow_coverage_percent', params.coveredPercent)
end

M.on_attach = function(client)
  local orig_callback = vim.lsp.handlers['textDocument/publishDiagnostics']
  local new_callback = function(a1, a2, params, client_id, bufnr, config)
    orig_callback(a1, a2, params, client_id, bufnr, config)

    local errors = vim.lsp.diagnostic.get_count(bufnr, "Error")
    if errors > 0 then return end

    if client_id == client.id then
      M.check_coverage()
    end
  end
  vim.lsp.handlers['textDocument/publishDiagnostics'] = new_callback
  M.check_coverage()
  vim.cmd [[autocmd InsertLeave <buffer> lua require'flow'.check_coverage()]]
end

M.check_coverage = function(bufnr)
  params = {
    textDocument = {
       uri = vim.uri_from_bufnr(bufnr)
    }
  }
  vim.lsp.buf_request(bufnr, 'textDocument/typeCoverage', params)
end

M.get_coverage_percent = function(bufnr)
  return vim.api.nvim_buf_get_var(bufnr, 'flow_coverage_percent')
end

return M
