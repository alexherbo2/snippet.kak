# snippets.kak

Snippets for [Kakoune].

## Features

- Static menu
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

## Options

- `snippets_directories`: List of snippets directories.  Default: `~/.config/kak/snippets` `/path/to/snippets.kak/snippets`.
- `snippets_placeholder`: Regex to select snippet placeholders.  Default: `\{[\w-]*\}`.

[Kakoune]: https://kakoune.org
