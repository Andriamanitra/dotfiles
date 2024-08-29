local micro = import("micro")
local buffer = import("micro/buffer")
local config = import("micro/config")

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
end
