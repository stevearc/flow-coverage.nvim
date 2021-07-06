local DiagnosticSeverity = vim.lsp.protocol.DiagnosticSeverity

local M = {}
local MESSAGE = "Uncovered code"

local function convert_coverage_to_diagnostics(coverage)
  local diagnostics = coverage.uncoveredRanges
  for _, diag in ipairs(diagnostics) do
    diag.message = MESSAGE
    diag.severity = DiagnosticSeverity.Warning
  end
  return diagnostics
end

local function hash_diagnostic(diagnostic)
  return string.format(
    "%s:%s-%s:%s",
    diagnostic.range.start.line,
    diagnostic.range.start.character,
    diagnostic.range["end"].line,
    diagnostic.range["end"].character
  )
end

local adding_type_diagnostics = false
vim.lsp.handlers["textDocument/typeCoverage"] = function(err, _, params, client_id, bufnr)
  if err ~= nil then
    error(err)
    return
  end

  local type_diagnostics = convert_coverage_to_diagnostics(params)
  local diagnostics = vim.lsp.diagnostic.get(bufnr, client_id)
  local seen = {}
  for _, diag in ipairs(diagnostics) do
    if diag.message == MESSAGE then
      seen[hash_diagnostic(diag)] = true
    end
  end
  for _, diag in ipairs(type_diagnostics) do
    -- Avoid adding duplicate type coverage diagnostics
    if not seen[hash_diagnostic(diag)] then
      table.insert(diagnostics, diag)
    end
  end

  adding_type_diagnostics = true
  pcall(
    vim.lsp.diagnostic.on_publish_diagnostics,
    nil,
    nil,
    { uri = vim.uri_from_bufnr(bufnr), diagnostics = diagnostics },
    client_id
  )
  adding_type_diagnostics = false

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
  if adding_type_diagnostics then
    return
  end
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
