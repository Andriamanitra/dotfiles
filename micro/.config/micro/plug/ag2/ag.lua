-- improved version of https://github.com/sebkolind/micro-ag
PLUGIN_VERSION = "2.0.0"
PLUGIN_NAME = "ag2"

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local buffer = import("micro/buffer")
local go_strings = import("strings")
local go_filepath = import("filepath")

function init()
    config.MakeCommand("ag", ag, config.NoComplete)
    config.AddRuntimeFile("ag2", config.RTHelp, "help/ag2.md")
end

function ag(bp, userargs)
    local args = go_strings.Join(userargs, " ")
    local output, err = shell.RunCommand("ag " .. args)

    if err == nil then
        createHorizontalSplitWithSearchResults(output)
    elseif err:Error() == "exit status 1" then
        micro.InfoBar():Message("[ag2] no search results")
    elseif err ~= nil then
        micro.InfoBar():Error("[ag2] " .. err:Error())
    end

end

function createHorizontalSplitWithSearchResults(output)
    local newBuffer = buffer.NewBuffer(output, "ag search results")
    newBuffer.Type.Scratch = true
    newBuffer.Type.Readonly = true

    micro.CurPane():HSplitBuf(newBuffer)
end

function openResultInCurrentPane(bp)
    local fpath, loc = getFilePathFromCurrentLine(bp.Buf)

    if fpath == nil then
        return false
    else
        local newBuffer = buffer.NewBufferFromFile(fpath)
        bp:OpenBuffer(newBuffer)
        gotoLoc(bp, loc)
        return true
    end
end

function openResultInTab(bp)
    local fpath, loc = getFilePathFromCurrentLine(bp.Buf)

    if fpath == nil then
        return false
    else
        local newBuffer = buffer.NewBufferFromFile(fpath)
        bp:AddTab()
        bp = micro.CurPane()
        bp:OpenBuffer(newBuffer)
        gotoLoc(bp, loc)
        return true
    end
end

function openResultSmart(bp, closeResults)
    local fpath, loc = getFilePathFromCurrentLine(bp.Buf)

    if fpath == nil then
        return false
    else
        local matchingBufPane, tabIdx, paneIdx = findBufPaneByPath(fpath)

        if matchingBufPane ~= nil then
            if micro.Tabs():Active() ~= tabIdx then
                matchingBufPane:tab():SetActive(paneIdx)
                micro.Tabs():SetActive(tabIdx)
            end
            gotoLoc(matchingBufPane, loc)
        else
            local newBuffer = buffer.NewBufferFromFile(fpath)
            bp:AddTab()
            local newbp = micro.CurPane()
            newbp:OpenBuffer(newBuffer)
            gotoLoc(newbp, loc)
        end
        if closeResults then bp:HandleCommand("quit") end
        return true
    end
end

function openResultSmartAndClose(bp)
    openResultSmart(bp, true)
end

function gotoLoc(bp, loc)
    local cursor = bp.Buf:GetActiveCursor()

    -- get rid of current selection because having something
    -- selected messes up moving the cursor
    cursor:Deselect(false)

    cursor:GotoLoc(loc)
    bp:Center()
end

function getFilePathFromCurrentLine(buf)
    if not (buf.Type.Scratch and buf.Type.Readonly) then
        return nil
    end

    local currentLine = buf:Line(buf:GetActiveCursor().Y)
    local fpath, linenum, colnum = currentLine:match("^([^:]+):(%d+):?(%d*)")


    if fpath == nil then
        micro.InfoBar():Error("[ag2] No filename found at current line")
        return nil
    end

    fpath = go_filepath.Abs(fpath)

    linenum = tonumber(linenum) - 1

    if colnum == "" then
        colnum = 0
    else
        colnum = tonumber(colnum) - 1
    end

    return fpath, buffer.Loc(colnum, linenum)
end

function findBufPaneByPath(filename)
    for tabIdx, tab in userdataIterator(micro.Tabs().List) do
        for paneIdx, pane in userdataIterator(tab.Panes) do
            -- pane.Buf is nil for panes that are not BufPanes (terminals etc)
            if pane.Buf ~= nil and filename == pane.Buf.AbsPath then
                -- lua indices start from 1 (yay!), go indices start from 0 (eww!)
                return pane, tabIdx - 1, paneIdx - 1
            end
        end
    end
end

function userdataIterator(data)
    local idx = 0
    return function ()
        idx = idx + 1
        local success, item = pcall(function() return data[idx] end)
        if success then return idx, item end
    end
end
