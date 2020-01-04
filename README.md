# Snippets

[![Build Status][Badge]][Travis]
[![IRC][IRC Badge]][IRC]

###### [Usage](#usage) | [Documentation](#commands) | [Contributing](CONTRIBUTING)

> [Kakoune] extension to expand snippets when validating with <kbd>Return</kbd>.  
> No magic, no predefined snippets.  
> A snippet expansion is as you would type it interactively.  

## Installation

### [Pathogen]

``` kak
pathogen-infect /home/user/repositories/github.com/alexherbo2/snippets.kak
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
the snippet will expand to:

``` kak
define-command ▌ %{X}
```

Leaving you the insert of the command name.
You can then press <kbd>n</kbd> to fill the command implementation.

### Snippets from file using [Crystal]

Generate snippets on-demand using `snippets-generate-config` and `snippets-source-config`.

``` yaml
File: ~/.config/snippets.yml
```

``` kak
hook global KakBegin .* %{
  snippets-source-config
}

define-command snippets-source-config %{
  try %{
    source "%val(client_env_XDG_CACHE_HOME)/kak/snippets.kak"
  }
}

define-command snippets-generate-config %{
  # Ensure ~/.cache/kak exists
  nop %sh{
    mkdir -p "$XDG_CACHE_HOME/kak"
  }
  # Snippets from file using Crystal
  # File: ~/.config/snippets.yml
  echo -to-file "%val(client_env_XDG_CACHE_HOME)/kak/snippets.kak" %sh{
    cat <<'EOF' | crystal eval
      require "yaml"
      class String
        def shell_escape
          "'" + self.gsub("'", %('"'"')) + "'"
        end
      end
      yaml = File.open(File.join(ENV["XDG_CONFIG_HOME"], "snippets.yml")) do |file|
        Hash(String, String).from_yaml(file)
      end
      yaml.each do |snippet, expansion|
        puts "
          set-option -add global snippets #{snippet.shell_escape} #{expansion.shell_escape}
          set-option -add global static_words #{snippet.shell_escape}
        "
      end
EOF
  }
}
```

**Example**

`~/.config/snippets.yml`

``` yaml
cat: 🐈
crab: 🦀
```

## Commands

- `snippets-enable`: Enable snippets
- `snippets-disable`: Disable snippets
- `snippets-toggle`: Toggle snippets

## Options

- `snippets` `str-list`: List of – `{snippet} {expansion}` – snippets (Default: Empty)
- `snippets_enabled` `bool`: Information about the way snippets are active (Read-only)

## Credits

Initial implementation by [danr].

[Kakoune]: https://kakoune.org
[Crystal]: https://crystal-lang.org
[Travis]: https://travis-ci.org/alexherbo2/snippets.kak
[Badge]: https://travis-ci.org/alexherbo2/snippets.kak.svg
[IRC]: https://webchat.freenode.net/#kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[Pathogen]: https://github.com/alexherbo2/pathogen.kak
[danr]: https://github.com/danr
