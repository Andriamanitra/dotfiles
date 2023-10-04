# ag2

Provides the ability to search code with `ag` (the_silver_searcher).

## Requirements

You must have `ag` available in your `$PATH`. Installation instructions:
https://github.com/ggreer/the_silver_searcher#installing

## Configuration

Available keybindings are:

- `lua:ag2.openResultSmart` - focus the result in a currently open buffer or open
  it in a new tab if it wasn't open yet
- `lua:ag2.openResultSmartAndClose` - same as above but also close the search results
- `lua:ag2.openResultInCurrentPane` - replace the search result pane with the result
- `lua:ag2.openResultInTab` - open the search result in a new tab

The keybindings only work in scratch panes that are marked read-only.

To use Enter/Alt-Enter to open search results without losing the ability to use
Enter to type newlines add this to bindings.json:

```json
{
  "Enter": "lua:ag2.openResultSmart|InsertNewline",
  "Alt-Enter": "lua:ag2.openResultSmartAndClose"
}
```
