local micro = import("micro")
local buffer = import("micro/buffer")
local config = import("micro/config")
local shell = import("micro/shell")
local go_filepath = import("filepath")

function gh_branch(bp, remote_branch, fpath)
    -- github redirects master to main if master is not found
    remote_branch = remote_branch or "origin/master"
    fpath = fpath or bp.Buf.AbsPath

    local remote_name, branch_name = remote_branch:match("^([^/]+)/(.+)$")
    if remote_name == nil then
        remote_name = "origin"
        branch_name = remote_branch
    end

    local remote_url, git_root = get_remote_url(remote_name, fpath)
    if remote_url == nil then return nil end
    local host, repo = parse_remote_url(remote_url)

    local git_fpath = sh("git", "-C", git_root, "ls-files", "--full-name", "--", fpath)
    if git_fpath == nil then
        micro.InfoBar():Error("gh: `git ls-files --full-name` failed!")
        return
    end

    if host == nil then
        micro.InfoBar():Error(("gh: Unsupported remote url '%s'"):format(remote_url))
        return
    end

    if host == "codeberg.org" then
        return ("https://%s/%s/src/branch/%s/%s"):format(host, repo, branch_name, git_fpath)
    end

    if host == "github.com" or host == "gitlab.org" then
        return ("https://%s/%s/blob/%s/%s"):format(host, repo, branch_name, git_fpath)
    end

    return ("https://%s/%s"):format(host, repo)
end

function gh_file(bp, fname)
    return gh_branch(bp, nil, fname)
end

function gh_pr(bp, pr_number, remote_name)
    remote_name = remote_name or "origin"

    local remote_url = get_remote_url(remote_name, bp.Buf.AbsPath)
    if remote_url == nil then return nil end
    local host, repo = parse_remote_url(remote_url)

    if host == nil then
        return nil
    elseif host == "github.com" then
        if pr_number == nil then
            return ("https://github.com/%s/pulls"):format(repo)
        else
            return ("https://github.com/%s/pull/%d"):format(repo, pr_number)
        end
    else
        micro.InfoBar():Error(("gh: Unsupported remote url '%s'"):format(remote_url))
        return nil
    end
end

function gh_issues(bp, issue_number, remote_name)
    remote_name = remote_name or "origin"

    local remote_url = get_remote_url(remote_name, bp.Buf.AbsPath)
    if remote_url == nil then return nil end
    local host, repo = parse_remote_url(remote_url)

    if host == nil then
        return nil
    elseif host == "github.com" then
        if issue_number == nil then
            return ("https://github.com/%s/issues"):format(repo)
        else
            return ("https://github.com/%s/issues/%d"):format(repo, issue_number)
        end
    else
        micro.InfoBar():Error(("gh: Unsupported remote url '%s'"):format(remote_url))
        return nil
    end
end

local subcommands = {
    ["branch"] = gh_branch,
    ["file"] = gh_file,
    ["issues"] = gh_issues,
    ["pr"] = gh_pr,
}

function init()
    local gh_completer = function (buf)
        local s = buf:Line(0):gsub("^gh ", "")

        local completions = {}
        local suggestions = {}
        for subcomm, _ in pairs(subcommands) do
            if string.find(subcomm, s, 1, true) == 1 then
                table.insert(completions, subcomm:sub(#s + 1, #subcomm) .. " ")
                table.insert(suggestions, subcomm)
            end
        end

        return completions, suggestions
    end

    config.MakeCommand("gh", gh, gh_completer)
end

function gh(bp, args)
    local subc = #args >= 1 and args[1] or "file"
    local arg1 = #args >= 2 and args[2] or nil
    local arg2 = #args >= 3 and args[3] or nil

    local subcommand = subcommands[subc]
    if subcommand == nil then
        micro.InfoBar():Message(("gh: Invalid subcommand '%s'"):format(subc))
        return
    end

    local gh_url = subcommand(bp, arg1, arg2)
    if gh_url then
        micro.InfoBar():Message(("gh$ xdg-open %s"):format(gh_url))
        sh("xdg-open", gh_url)
    end
end

function sh(...)
    local result, err = shell.ExecCommand(...)
    if err ~= nil then
        return nil
    else
        return result:gsub("\n", "")
    end
end

function get_remote_url(remote_name, fpath)
    local fdir = go_filepath.Dir(fpath)

    local git_root = sh("git", "-C", fdir, "rev-parse", "--show-toplevel")
    if git_root == nil then
        micro.InfoBar():Error("gh: File is not in a git repository!")
        return nil
    end

    local remote_url = sh("git", "-C", git_root, "remote", "get-url", remote_name)
    if remote_url == nil then
        micro.InfoBar():Error(("gh: No remote called '%s'"):format(remote_name))
        return nil
    end

    return remote_url, git_root
end

function parse_remote_url(remote_url)
    local remote_patterns = {
      "^git@([^:]+):(.+)$",
      "^ssh://git@([^/]+)/(.+)$",
      "^git://([^/]+)/(.+)$",
      "^https://([^/]+)/(.+)$",
    }
    remote_url = remote_url:gsub("%.git$", "")
    for _, patt in ipairs(remote_patterns) do
        local host, repo = remote_url:match(patt)
        if host ~= nil then
            return host, repo
        end
    end
    return nil, nil
end
