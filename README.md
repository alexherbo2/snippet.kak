# snippets.kak

Snippets for [Kakoune].

## Dependencies

- [prelude.kak]
- [type-expand.kak]

[prelude.kak]: https://github.com/alexherbo2/prelude.kak
[type-expand.kak]: https://github.com/alexherbo2/type-expand.kak

## Installation

Add [`snippets.kak`](rc/snippets.kak) to your autoload or source it manually.

## Usage

- <kbd>Alt</kbd> + <kbd>Return</kbd> ⇒ Expand the currently entered snippet 
⚠  For the simplicity of the implementationThe snippet must be inside matching pair:
`div-class` will not expand but `(div-class)` will
- <kbd>Alt</kbd> + <kbd>n</kbd> ⇒ Select the next placeholder.
- <kbd>Alt</kbd> + <kbd>p</kbd> ⇒ Select the previous placeholder.

## Commands

- `snippets-enable`: Enable snippets.
- `snippets-disable`: Disable snippets.
- `snippets-expand-selection`: Expand selected snippet.
- `snippets-list` (`sl`): Visualize snippets in a scratch buffer.

## Options

- `snippets_directories`: List of snippets directories.  Default: `~/.config/kak/snippets` `/path/to/snippets.kak/snippets`.
- `snippets_placeholder`: Regex to select snippet placeholders.  Default: `\{[\w-]*\}`.

[Kakoune]: https://kakoune.org
