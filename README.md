# Snippets

[![Build Status][Badge]][Travis]
[![IRC][IRC Badge]][IRC]

###### [Usage](#usage) | [Documentation](#commands) | [Contributing](CONTRIBUTING)

> [Kakoune] extension to expand snippets when validating with <kbd>Return</kbd>.  
> No magic, no predefined snippets.  
> A snippets expansion is as you would type it interactively.  

## Installation

``` sh
ln --symbolic $PWD/rc $XDG_CONFIG_HOME/kak/autoload/snippets
```

## Usage

### Activation

``` kak
hook global WinCreate .* %{
  snippets-enable
}
```

### Global settings

``` kak
set-option -add global snippets '->' '→'
```

### Per file-type settings

``` kak
hook global WinSetOption filetype=kak %{
  set-option -add window snippets def 'define-command X %{X}<esc><a-/>X<ret><a-n>c'
}
```

This settings enables to expand [Kakoune] code.
By inserting `def` and validating with <kbd>Return</kbd>,
the snippets will expand to:

``` kak
define-command ▌ %{X}
```

Leaving you the insert of the command name.
You can then press <kbd>n</kbd> to fill the command implementation.

## Commands

- `snippets-enable`: Enable snippets
- `snippets-disable`: Disable snippets
- `snippets-toggle`: Toggle snippets

## Options

- `snippets` `str-list`: List of – `{key} {value}` – snippets (Default: Empty)
- `snippets_enabled` `bool`: Information about the way snippets are active (Read-only)

## Credits

Initial implementation by [danr].

[Kakoune]: http://kakoune.org
[Travis]: https://travis-ci.org/alexherbo2/snippets.kak
[Badge]: https://travis-ci.org/alexherbo2/snippets.kak.svg
[IRC]: https://webchat.freenode.net?channels=kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[danr]: https://github.com/danr
