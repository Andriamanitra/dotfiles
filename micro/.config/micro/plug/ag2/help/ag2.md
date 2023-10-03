# ag2

Provides the ability to search code with `ag` (the_silver_searcher).

## Requirements

You must have `ag` available in your `$PATH`. Installation instructions:
https://github.com/ggreer/the_silver_searcher#installing

## Configuration

Available keybindings are:

- `lua:ag2.showResult` - focus the result in a currently open buffer or open it
  in a new tab if it wasn't open yet
- `lua:ag2.openInCurrentPane` - replace the search result pane with the result
- `lua:ag2.openInTab` - open the search result in a new tab The keybindings only
  work in the search results pane.

To use Enter/Alt-Enter to open search results without losing the ability to use
Enter to type newlines add this to bindings.json:

```json
{
  "Enter": "lua:ag2.showResult|InsertNewline",
  "Alt-Enter": "lua:ag2.openInCurrentPane"
}
```
