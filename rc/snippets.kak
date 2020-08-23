hook global ModuleLoaded snippets %{
  snippets-enable
}

provide-module snippets %{

  # Modules
  require-module prelude
  require-module phantom

  # Buffer scope
  declare-option -docstring 'Buffer scope' str-list snippets_scope

  # Commands
  define-command snippets-enable -docstring 'Enable snippets' %{
    map global insert <a-ret> '<a-;>: snippets-menu<ret>/'
  }

  define-command snippets-disable -docstring 'Disable snippets' %{
    unmap global insert <a-ret>
  }

  # Main interface to insert snippets
  define-command snippets-menu -docstring 'Menu for snippets' %{
    evaluate-commands %sh{
      # Prelude
      . "$kak_opt_prelude_path"

      sh_quoted_snippets_as_tuples=$(snippets get snippets global "$kak_opt_filetype" $kak_opt_snippets_scope | jq --sort-keys | jq --raw-output '[.[] | .name, .content] | @sh')

      eval "set -- $sh_quoted_snippets_as_tuples"

      kak_escape_partial menu -select-cmds --
      while [ "$2" ]; do
        name=$1
        content=$2
        shift 2

        kak_escape_partial "$name" "$(kak_escape snippets-insert "$content")" "$(kak_escape info "$content")"
      done
    }
  }

  # Insert text with proper indentation and quickly jump to the next placeholder with phantom.kak.
  define-command -hidden snippets-insert -params 1 %{
    try %{
      evaluate-commands -draft %{
        snippets-insert-text %arg{1}
        set-register / '\{\{.*?\}\}'
        execute-keys 's<ret>'
        phantom-save
      }
    }
  }

  # Utility command to add a scope for a matching path
  # snippets-add-scope <option-scope> <snippets-scope> <buffer-path>
  define-command -hidden snippets-add-scope -params 3 %{
    hook -always -once window User "snippets-buffer-path=%arg{3}" "
      set-option -add %arg{1} snippets_scope %arg{2}
    "

    trigger-user-hook "snippets-buffer-path=%val{buffile}"
  }

  # Generics to insert text with proper indentation.
  define-command -hidden snippets-replace-text -params 1 %{
    snippets-paste-text 'R' %arg{1}
  }

  define-command -hidden snippets-insert-text -params 1 %{
    snippets-paste-text '<a-P>' %arg{1}
  }

  define-command -hidden snippets-append-text -params 1 %{
    snippets-paste-text '<a-p>' %arg{1}
  }

  define-command -hidden snippets-paste-text -params 2 %{
    evaluate-commands -save-regs '"' %{
      # Paste using the specified method.
      # The command (R, <a-P> and <a-p>) selects inserted text.
      set-register '"' %arg{2}
      execute-keys %arg{1}

      # Replace leading tabs with the appropriate indent.
      try %{
        evaluate-commands %sh{
          if test "$kak_opt_indentwidth" -eq 0; then
            printf fail
          fi
        }
        execute-keys -draft "<a-s>s\A\t+<ret>s.<ret>%opt{indentwidth}@"
      }

      # Align everything with the current line.
      evaluate-commands -draft -itersel %{
        try %{
          execute-keys '<a-s>Z)<space><a-x>s^\h+<ret>yz)<a-space>_P'
        }
      }
    }
  }
}

require-module snippets
