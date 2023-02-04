import sublime
import sublime_plugin
import random


class PromptTempFileCommand(sublime_plugin.WindowCommand):
    def run(self):
        #self.window.show_input_panel("what up:", "asd", self.callback, None, None)
        randomized = "".join(random.choices("tmpfile", k=9))
        self.window.show_input_panel("Save as:", f"/tmp/t{randomized}", self.callback, None, None)

    def callback(self, fname):
        view = self.window.active_view()
        if view:
            view.retarget(fname)
            view.run_command("save")
            syntax = sublime.find_syntax_for_file(fname)
            if syntax:
                view.assign_syntax(syntax)
