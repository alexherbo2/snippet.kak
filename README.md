# snippets.kak

[Snippets] for [Kakoune].

[Snippets]: https://github.com/alexherbo2/snippets
[Kakoune]: https://kakoune.org

## Dependencies

- [Snippets]
- [prelude.kak]
- [phantom.kak]

[prelude.kak]: https://github.com/alexherbo2/prelude.kak
[phantom.kak]: https://github.com/alexherbo2/phantom.kak

## Installation

Add [`rc`](rc) to your autoload or source [`snippets.kak`](rc/snippets.kak) and its [modules](rc/modules) manually.

## Usage

Press <kbd>Alt</kbd> + <kbd>Enter</kbd> to insert a snippet.
You can quickly jump to the next placeholder with [phantom.kak].

## Configuration

**Example**

``` kak
# Modules
require-module snippets-crystal

# Options
set-option global snippets_scope global
```
