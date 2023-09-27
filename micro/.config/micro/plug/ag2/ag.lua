-- improved version of https://github.com/sebkolind/micro-ag
PLUGIN_VERSION = "2.0.0"
PLUGIN_NAME = "ag2"

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local strings = import("strings") 
local buffer = import("micro/buffer")

function init()
    config.MakeCommand("ag", ag, config.NoComplete)
end

function ag(bp, userargs)
    local args = strings.Join(userargs, " ")
    local output, err = shell.RunCommand("ag " .. args)

    if err ~= nil then
        micro.InfoBar():Error(err)
        return
    end

    createHorizontalSplitWithSearchResults(output)
end

function createHorizontalSplitWithSearchResults(output)
    local newBuffer = buffer.NewBuffer(output, "ag search results")

    newBuffer.Type.scratch = true
    newBuffer.Type.Readonly = true

    micro.CurPane():HSplitBuf(newBuffer)
end

function openInBufPane(bp, filename)
    if filename == nil then return end
    local newBuffer = buffer.NewBufferFromFile(filename)
    bp:OpenBuffer(newBuffer)
    bp:Center()
end

function openInTab(bp, filename)
    if filename == nil then return end
    bp:HandleCommand("tab " .. filename)
    bp:Center()
end

function getFilenameFromCurrentLine(bp)
    local cursor = bp.Cursor
    local currentLine = bp.Buf:Line(cursor.Y)
    local found = currentLine:match("([^:]+:%d+)")
    
    if found == nil then
        micro.InfoBar():Error("[ag2] No filename found at current line")
    end

    return found
end

function findBufPaneByPath(fname)
    for tabIdx, tab in userdataIterator(micro.Tabs().List) do
        for paneIdx, pane in userdataIterator(tab.Panes) do
            -- TODO: maybe sometimes absolute path is necessary?
            -- pane.Buf is nil for panes that are not BufPanes (terminals etc)
            if pane.Buf ~= nil and fname == pane.Buf.path then
                return pane, tabIdx, paneIdx
            end
        end
    end
end

function preRune(bp, rune)
    if bp.Buf.path == "ag search results" then
        if rune == "q" or rune == "z" then
            bp:HandleCommand("quit")
        elseif rune == "x" then
            local filename = getFilenameFromCurrentLine(bp)
            openInBufPane(bp, filename)
        end
        return false
    end
    return true
end

-- open the search result when Enter is pressed
function onInsertNewline(bp)
    if bp.Buf.path == "ag search results" then
        local fname = getFilenameFromCurrentLine(bp)
        if fname == nil then return end

        -- switch to the correct buffer if the file was already open, otherwise open a new tab
        local matchingBufPane, tabIdx, paneIdx = findBufPaneByPath(fname:match("[^:]+"))

        if matchingBufPane ~= nil then
            local cursor = matchingBufPane.Buf:GetActiveCursor()
            local linenum = tonumber(fname:match("[^:]+:(%d+)"))

            -- get rid of current selection because having something
            -- selected messes up moving the cursor
            cursor:Deselect(false)

            cursor:GotoLoc(buffer.Loc(0, linenum - 1))
            matchingBufPane:Center()

            -- lua indices start from 1 (yay!), go indices start from 0 (eww!)
            matchingBufPane:tab():SetActive(paneIdx - 1)
            micro.Tabs():SetActive(tabIdx - 1)
        else            
            openInTab(bp, fname)
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
