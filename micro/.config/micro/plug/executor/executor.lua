VERSION = "2.0.0"

local executor_map = {
  ["asm"]        = "make run",
  ["awk"]        = "awk -f '%s'",
  ["c"]          = "zig run -lc '%s'",
  ["c++"]        = "sh -c \"g++ -std=c++20 -o /tmp/prog '%s' && /tmp/prog\"",
  ["crystal"]    = "crystal run '%s'",
  ["d"]          = "dmd -run '%s'",
  ["janet"]      = "janet '%s'",
  ["javascript"] = "node '%s'",
  ["julia"]      = "julia '%s'",
  ["justfile"]   = "just -f '%s'",
  ["lisp"]       = "sbcl --script '%s'",
  ["lua"]        = "lua '%s'",
  ["nim"]        = "nim r '%s'",
  ["haskell"]    = "runhaskell '%s'",
  ["html"]       = "xdg-open '%s'",
  ["python"]     = "python3 '%s'",
  ["racket"]     = "racket '%s'",
  ["ruby"]       = "ruby '%s'",
  ["rust"]       = "cargo run",
  ["shell"]      = "sh '%s'",
  ["uiua"]       = "uiua run --no-format '%s'",
  ["zig"]        = "zig run '%s'",
}
-- if override_template is set with set_exec_template command,
-- its value is used instead of executor_map
local override_template = nil

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local go_strings = import("strings")

function init()
  config.MakeCommand("exec", execute, config.NoComplete)
  config.MakeCommand("set_exec_template", set_template, config.NoComplete)
end

function set_template(bp, args)
  local hasArgs = pcall(function() return args[1] end)
  if hasArgs then
    override_template = go_strings.Join(args, " ")
  else
    override_template = nil
  end
end

function execute(bufpane, args)
  local hasArgs = pcall(function() return args[1] end)
  local ftype = micro.CurPane().Buf:FileType()
  local cmd_template = executor_map[ftype]

  if hasArgs then
    cmd_template = go_strings.Join(args, " ")
  elseif override_template then
    cmd_template = override_template
  elseif cmd_template == nil then
    local errmsg = string.format("can't exec, unknown filetype '%s' :(", ftype)
    micro.InfoBar():Message(errmsg)
    return
  end

  local runcmd = string.format(cmd_template, bufpane.Buf.Path)
  local wait_for_user = true
  local return_output = false
  shell.RunInteractiveShell(runcmd, wait_for_user, return_output)
  micro.InfoBar():Message(string.format("Executed \"%s\"", runcmd))
end
