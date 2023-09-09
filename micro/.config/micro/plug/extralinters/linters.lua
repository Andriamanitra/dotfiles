local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")

function init()
    linter.makeLinter("ruff", "python", "ruff", {"%f"}, "%f:%l:%c: %m")
    config.MakeCommand("ruffix", ruffix, config.NoComplete)
end

function ruffix()
    local buf = micro.CurPane().Buf

    -- ruff doesn't do much formatting so let's also use autopep8
    -- (using autopep8 instead of black because black doesn't want
    -- you to align things with extra spaces)
    shell.ExecCommand("autopep8", "--in-place", buf.Path)

    shell.ExecCommand("ruff", "--fix", buf.Path)

    -- without this the changes won't show up and micro will prompt
    -- to reopen current buffer because file on disk has changed
    buf.ReOpen(buf)

    -- without this the linter warnings in the gutter don't update
    linter.runLinter(buf)
end