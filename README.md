# snippets.kak

Snippets for [Kakoune].

## Features

- File-based snippets
- Support for sub-snippets: `{{snippet-name}}` in a snippet file.
- Support for modes:
  a mode is just an additional directory with languages in it,
  and is active when in your `snippets_directories` option.
- Support for aliases: an alias is just a symlink.
- Static menu
- List and preview snippets
- No `sh` call when typing

## Dependencies

- [prelude.kak]

[prelude.kak]: https://github.com/alexherbo2/prelude.kak

## Installation

Add [`snippets.kak`](rc/snippets.kak) to your autoload or source it manually.

## Usage

- <kbd>Alt</kbd> + <kbd>Return</kbd> ⇒ Menu for snippets.
- <kbd>Alt</kbd> + <kbd>n</kbd> ⇒ Select the next placeholder.
- <kbd>Alt</kbd> + <kbd>p</kbd> ⇒ Select the previous placeholder.

## Commands

- `snippets-enable`: Enable snippets.
- `snippets-disable`: Disable snippets.
- `snippets-menu`: Menu for snippets.
- `snippets-insert`: Insert snippets.

## Options

- `snippets_directories`: List of snippets directories.  Default: `~/.config/kak/snippets` `/path/to/snippets.kak/snippets`.
- `snippets_cache_path`: Path to snippets cache.  Default: `$XDG_CACHE_HOME/kak/snippets` or `~/.cache/kak/snippets`.

[Kakoune]: https://kakoune.org
