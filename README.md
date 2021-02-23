# snippets.kak

[Snippets] integration for [Kakoune].

[Snippets]: https://github.com/alexherbo2/snippets
[Kakoune]: https://kakoune.org

## Dependencies

- [Snippets]
- [jq]
- [kakoune.cr]
- [execute-key.kak]
- [phantom.kak]

[jq]: https://stedolan.github.io/jq/
[kakoune.cr]: https://github.com/alexherbo2/kakoune.cr
[execute-key.kak]: https://github.com/alexherbo2/execute-key.kak
[phantom.kak]: https://github.com/alexherbo2/phantom.kak

## Installation

Add [`snippets.kak`](rc/snippets.kak) to your autoload or source it manually.

``` kak
require-module snippets
```

## Usage

Enable snippets with `snippets-enable`.

Type `/` to bring the snippets completions,
select a snippet in the list of completions and press <kbd>Enter</kbd>,
or directly <kbd>Alt</kbd> + <kbd>Enter</kbd> to insert a snippet.
You can quickly jump to the next placeholder with [phantom.kak].

## Configuration

**Example**

``` kak
# Options
set-option global snippets_scope global

# Mappings
# Create new snippets
map -docstring 'Edit snippets' global user / ': snippets-edit<ret>'

# Optional auto-pairs integration
map -docstring 'Expand snippets' global insert <ret> '<a-;>: snippets-enter auto-pairs-insert-new-line<ret>'

# Hooks
# Indent snippets with tabs
hook global BufCreate '.+/\.?config/snippets/.+' %{
  set-option buffer indentwidth 0
}
```
