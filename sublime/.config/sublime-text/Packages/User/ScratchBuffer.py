# This is based on the scratch_buffer plugin at
# https://github.com/STealthy-and-haSTy/SublimeScraps

import sublime
import sublime_plugin
import os
import re
import random

NAME_REGEX = re.compile(r'^name:\s+([^\r\n]+|\'[^\']+\')$', re.MULTILINE)


def _syntax_name(syntax_res):
    syntax_file = os.path.basename(syntax_res)
    name, ext = os.path.splitext(syntax_file)

    if ext == '.sublime-syntax':
        contents = sublime.load_resource(syntax_res)
        # a hack to read the name from the YAML without parsing the file
        match = re.search(NAME_REGEX, contents)
        if match:
            name = match.group(1)

    return name


class SyntaxListInputHandler(sublime_plugin.ListInputHandler):
    """
    Input handler for the syntax argument of the scratch_buffer command; allows
    for the selection of one of the available syntaxes.
    """
    def name(self):
        return "syntax"

    def placeholder(self):
        return "Buffer Syntax"

    def preview(self, value):
        language = value.split("/")[1]
        fname = os.path.basename(value)
        return sublime.Html(f"<strong>{language}</strong>: <em>{fname}</em>")

    def list_items(self):
        langs = {}
        for syntax in sublime.find_resources("*.tmLanguage"):
            langs[_syntax_name(syntax)] = syntax
        for syntax in sublime.find_resources("*.sublime-syntax"):
            langs[_syntax_name(syntax)] = syntax
        return sorted(langs.items())


class ScratchBufferCommand(sublime_plugin.WindowCommand):
    """
    Create a scratch view with the provided syntax already set. If syntax is
    None, you get prompted to select a syntax first.
    """
    def run(self, syntax=None):
        if syntax is None:
            return self.query_syntax()

        view = self.window.new_file()
        view.assign_syntax(syntax)

        language = _syntax_name(syntax).replace(" ", "")
        randomized = "".join(random.choices("tmpfile", k=7))
        view.retarget(f"/tmp/Scratch: {language} ({randomized})")
        view.set_scratch(True)

    def input(self, args):
        if args.get("syntax", None) is None:
            return SyntaxListInputHandler()

    def input_description(self):
        return "Scratch:"

    def query_syntax(self):
        items = [list(val) for val in SyntaxListInputHandler().list_items()]

        def pick(idx):
            if idx != -1:
                self.run(syntax=items[idx][1])

        self.window.show_quick_panel(items, on_select=pick)
