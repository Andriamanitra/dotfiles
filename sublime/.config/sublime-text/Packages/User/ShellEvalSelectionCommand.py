# This is a modified version of the plugin found at
# https://github.com/jbrooksuk/Sublime-Evaluate

import sublime
import sublime_plugin
import threading
import subprocess


class ShellEvalSelectionCommand(sublime_plugin.TextCommand):
    def bashable(self, sel) -> bool:
        return self.view.substr(sel).lstrip().startswith("$ ")

    def is_visible(self):
        return all(self.bashable(sel) for sel in self.view.sel())

    def run(self, edit):
        threads = []
        timeout = 5
        for sel in self.view.sel():
            if self.bashable(sel):
                to_eval = self.view.substr(sel)
                thread = EvaluateShell(sel, to_eval, timeout)
                threads.append(thread)
                thread.start()

        offset = 0
        for t in threads:
            t.join(timeout)
            offset = self.replace(edit, t, offset)

        num_evaluated = len(threads)
        self.view.sel().clear()
        sublime.status_message(f"Evaluated {num_evaluated} selection(s)!")

    def replace(self, edit, thread, offset: int):
        sel = thread.sel
        original = thread.original
        result = thread.result

        if offset:
            sel = sublime.Region(sel.begin() + offset, sel.end() + offset)

        prefix = original
        main = str(result)
        self.view.replace(edit, sel, main)

        end_point = (sel.begin() + len(prefix) + len(main)) - len(original)
        self.view.sel().add(sublime.Region(end_point, end_point))

        return offset + len(main) - len(original)


class EvaluateShell(threading.Thread):
    def __init__(self, sel, to_eval, timeout):
        self.sel = sel
        self.original = to_eval
        self.timeout = timeout
        self.result = self.original  # Default result
        threading.Thread.__init__(self)

    def run(self):
        """
        Evaluates self.original with either shell or Python,
        save output to self.result
        """

        if self.original.lstrip().startswith("$ "):
            shell_code = self.original.lstrip()[2:]
            try:
                p = subprocess.Popen(
                    shell_code,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT
                )
                # stderr goes to stdout
                out, _ = p.communicate(timeout=self.timeout)

                if type(out) == bytes:
                    out = out.decode()

                self.result = out[:-1] if out.endswith("\n") else out
            except Exception as exc:
                print(f"EvalSelection: {exc}")
