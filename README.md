# Snippets

[![Build Status][Badge]][Travis]
[![IRC][IRC Badge]][IRC]

###### [Usage](#usage) | [Documentation](#commands) | [Contributing](CONTRIBUTING)

> [Kakoune][] extension to expand snippets when validating with <kbd>Return</kbd>.

## Dependencies

- [jq][]

## Installation

``` sh
ln --symbolic $PWD/rc $XDG_CONFIG_HOME/kak/autoload/snippets
```

## Usage

### Global settings

``` kak
set-option global snippets %{{
  "->": "→"
}}
```

### Per file-type settings

``` kak
hook global WinSetOption filetype=kak %{
  set-option buffer snippets %{{
    "def": "define-command X %{X}<esc><a-/>X<ret><a-n>c"
  }}
}
```

### Activation

``` kak
hook global WinCreate .* %{
  snippets-enable
}
```

## Commands

- `snippets-enable`: Enable snippets
- `snippets-disable`: Disable snippets
- `snippets-toggle`: Toggle snippets

## Options

- `snippets` `str`: [JSON][]-formatted string of snippets (Default: `{}`)
- `snippets_enabled` `bool`: Information about the way snippets are active (Read-only)

## Credits

Initial implementation by [danr][].

[Kakoune]: http://kakoune.org
[Travis]: https://travis-ci.org/alexherbo2/snippets.kak
[Badge]: https://travis-ci.org/alexherbo2/snippets.kak.svg
[IRC]: https://webchat.freenode.net?channels=kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[jq]: https://stedolan.github.io/jq/
[JSON]: https://json.org
[danr]: https://github.com/danr
