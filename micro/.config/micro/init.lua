local micro = import("micro")
local buffer = import("micro/buffer")
local config = import("micro/config")
local shell = import("micro/shell")
local util = import("micro/util")

local mark = buffer.Loc(0, 1337)

function addMark(bufpane)
    local cursor = bufpane.Buf:GetActiveCursor()
    mark = buffer.Loc(cursor.Loc.X, cursor.Loc.Y)
end

function goToMark(bufpane)
    local cursor = bufpane.Buf:GetActiveCursor()
    local prev = buffer.Loc(cursor.Loc.X, cursor.Loc.Y)
    cursor:GotoLoc(mark)
    mark = prev
    cursor:Relocate()
    bufpane:Relocate()
end

function selectToMark(bufpane)
    local cursor = bufpane.Buf:GetActiveCursor()
    local curr = buffer.Loc(cursor.Loc.X, cursor.Loc.Y)
    cursor:SetSelectionStart(mark)
    cursor:SetSelectionEnd(curr)
end

function init()
    config.MakeCommand("mark", addMark, config.NoComplete)
    config.MakeCommand("go-to-mark", goToMark, config.NoComplete)
    config.MakeCommand("select-to-mark", selectToMark, config.NoComplete)
    config.MakeCommand("bash", function () shell.RunInteractiveShell("bash", false, false) end, config.NoComplete)
    config.MakeCommand("fish", function () shell.RunInteractiveShell("fish", false, false) end, config.NoComplete)
end

local colonIndentable = {
    python = true,
    yaml = true,
    nim = true,
}

local shouldIndent = false

function runeBeforeCursor(buf)
    local cursor = buf:GetActiveCursor()
    if cursor.Loc.X == 0 then return "\n" end
    local locBefore = buffer.Loc(cursor.Loc.X - 1, cursor.Loc.Y)
    return util.RuneStr(buf:RuneAt(locBefore))
end

function preInsertNewline(bp)
    shouldIndent = colonIndentable[bp.Buf:FileType()] and runeBeforeCursor(bp.Buf) == ":"
end

function onInsertNewline(bp)
    if shouldIndent then bp:IndentLine() end
    shouldIndent = false
end
