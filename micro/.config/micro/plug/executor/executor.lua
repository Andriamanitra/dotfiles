VERSION = "1.0.0"

local executor_map = {
  ["asm"]        = "make run",
  ["awk"]        = "awk -f '%s'",
  ["c"]          = "make run",
  ["crystal"]    = "crystal run '%s'",
  ["d"]          = "dmd -run '%s'",
  ["janet"]      = "janet '%s'",
  ["javascript"] = "node '%s'",
  ["julia"]      = "julia '%s'",
  ["lisp"]       = "sbcl --script '%s'",
  ["haskell"]    = "runhaskell '%s'",
  ["html"]       = "xdg-open '%s'",
  ["python"]     = "python3 '%s'",
  ["racket"]     = "racket '%s'",
  ["ruby"]       = "ruby '%s'",
  ["rust"]       = "sh -c \"rustc -o /tmp/rust_prog '%s' && /tmp/rust_prog && rm /tmp/rust_prog\"",
  ["shell"]      = "sh '%s'",
  ["zig"]        = "zig run '%s'",
}
-- if override_template is set with set_exec_template command,
-- its value is used instead of executor_map
local override_template = nil

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")

function init()
  config.MakeCommand("exec", execute, config.NoComplete)
  config.MakeCommand("set_exec_template", set_template, config.NoComplete)
end

function set_template(bp, args)
  override_template = args[1]
end

function info(msg, ...)
  if select('#', ...) > 0 then
    msg = string.format(msg, ...)
  end
  micro.InfoBar():Message(msg)
end

function execute()
  local ftype = micro.CurPane().Buf:FileType()
  local cmd_template = executor_map[ftype]

  if override_template then
    cmd_template = override_template
  elseif cmd_template == nil then
    info("can't exec, unknown filetype '%s' :(", ftype)
    return
  end

  local filepath = micro.CurPane().Buf.Path
  local runcmd = string.format(cmd_template, filepath)
  local wait_for_user = true
  local return_output = false
  shell.RunInteractiveShell(runcmd, wait_for_user, return_output)
  info("Executed \"%s\"", runcmd)
end
