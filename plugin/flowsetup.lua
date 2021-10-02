local flow = require('flow')

-- Hook publishDiagnostics so that the flow client will always check type
-- coverage after receiving diagnostics
local diagnostics_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(...)
  diagnostics_handler(...)
  local config_or_client_id = select(4, ...)
  local is_new = type(config_or_client_id) ~= "number"
  local client_id, bufnr
  if is_new then
    local context = select(3, ...)
    client_id = context.client_id
    bufnr = context.bufnr
  else
    client_id = select(4, ...)
    bufnr = select(5, ...)
  end
  local client = vim.lsp.get_client_by_id(client_id)
  if client.server_capabilities.typeCoverageProvider then
    flow.check_coverage(bufnr)
  end
end

local DEFAULT_INTERVAL = 5000
local function start_timer()
  local timer = vim.loop.new_timer()
  local interval = vim.g.flow_coverage_interval or DEFAULT_INTERVAL
  timer:start(1000, interval, vim.schedule_wrap(function()
    flow.check_coverage(0)
    local new_interval = vim.g.flow_coverage_interval or DEFAULT_INTERVAL
    if new_interval ~= interval then
      timer:close()
      start_timer()
    end
  end))
end
start_timer()
