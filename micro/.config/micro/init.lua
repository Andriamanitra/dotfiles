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

function shortfname(buf)
    if buf.Path == "" then
        return "No name"
    end

    local home = os.getenv("HOME")
    if home ~= nil then
        return buf.Path:gsub("^" .. home, "~")
    end
    return buf.Path
end

function init()
    config.MakeCommand("mark", addMark, config.NoComplete)
    config.MakeCommand("go-to-mark", goToMark, config.NoComplete)
    config.MakeCommand("select-to-mark", selectToMark, config.NoComplete)
    config.MakeCommand("select-to-matching-brace", selectToMatchingBrace, config.NoComplete)

    micro.SetStatusInfoFn("initlua.shortfname")

    config.MakeCommand(
        "date",
        function (bp, args)
            local fmt = #args > 0 and args[1] or "%Y-%m-%d"
            micro.InfoBar():Message(os.date(fmt))
        end,
        config.NoComplete
    )

    config.MakeCommand(
        "bashmode",
        function (_bp, _args)
            local callback = function (resp, canceled)
                if not canceled and resp ~= "" then
                    local bashCmd = string.format("bash -c '%s'", resp)
                    local waitForUser = true
                    local getOutput = false
                    shell.RunInteractiveShell(bashCmd, waitForUser, getOutput)
                end
            end
            micro.InfoBar():Prompt("$ ", "", "Bash", nil, callback)
        end,
        config.NoComplete
    )

    config.MakeCommand(
        "pipemode",
        function (bufpane)
            local callback = function (resp, canceled)
                if not canceled and resp ~= "" then
                    bufpane:HandleCommand(string.format("textfilter sh -c '%s'", resp))
                end
            end
            micro.InfoBar():Prompt("|> ", "", "Textfilter", nil, callback)
        end,
        config.NoComplete
    )
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

function selectToMatchingBrace(bp)
    local buf = bp.Buf
    local cursors = buf:GetCursors()
    local i = 0
    while i < #cursors do
        i = i + 1
        local cursor = cursors[i]
        local originalLoc = -cursor.Loc
        matchingBraceLoc, left, found = buf:FindMatchingBrace(originalLoc)
        if found then
            if not left and buf.Settings["matchbraceleft"] then
                matchingBraceLoc = matchingBraceLoc:Move(1, buf)
            end
            if originalLoc:GreaterThan(matchingBraceLoc) then
                cursor:SetSelectionStart(matchingBraceLoc)
                cursor:SetSelectionEnd(originalLoc)
            else
                cursor:SetSelectionStart(originalLoc)
                cursor:SetSelectionEnd(matchingBraceLoc)
            end
        end
    end
end
