VERSION = "1.0.0"

local executor_map = {
  ["c"]       = "make run",
  ["crystal"] = "crystal run '%s'",
  ["d"]       = "dmd -run '%s'",
  ["julia"]   = "julia '%s'",
  ["haskell"] = "runhaskell '%s'",
  ["python"]  = "python3 '%s'",
  ["racket"]  = "racket '%s'",
  ["ruby"]    = "ruby '%s'",
}

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")

function init()
  config.MakeCommand("exec", execute, config.NoComplete)
end

function info(msg, ...)
  if select('#', ...) > 0 then
    msg = string.format(msg, ...)
  end
  micro.InfoBar():Message(msg)
end

function execute()
  local ftype = micro.CurPane().Buf:FileType()
  local cmd_template = executor_map[ftype];

  if cmd_template == nil then
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
