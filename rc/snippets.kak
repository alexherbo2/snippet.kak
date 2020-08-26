# Resources
# – https://zork.net/~st/jottings/Intro_to_Kakoune_completions.html
# – https://github.com/ul/kak-lsp

hook global ModuleLoaded snippets %{
  snippets-enable
}

provide-module snippets %{

  # Modules
  require-module prelude
  require-module phantom

  # Buffer scope
  # Example: crystal crystal/spec
  declare-option -docstring 'Buffer scope' str-list snippets_scope

  # Options for tuning snippets behavior.

  # Prefix to trigger snippets completion.
  # By default, it is the POSIX path separator.
  # Example: /
  declare-option -docstring 'Prefix to trigger snippets completion' str snippets_prefix '/'

  # Completions request is sent only when this expression does not fail.
  # By default, it ensures that preceding characters match a snippet path.
  # Example: /def▌
  declare-option -docstring 'Completions request is sent only when this expression does not fail' str snippets_completion_trigger %{
    set-register / "\Q%opt{snippets_prefix}\E\S*.\z"
    execute-keys '<a-h><a-k><ret>'
  }

  # Kakoune requires completions to point fragment start rather than cursor position.
  # This variable provides a way to customize how fragment start is detected.
  # By default, it tracks back to the first path separator.
  # Example: /[def]
  declare-option -docstring 'Select from cursor to the start of the term being completed' str snippets_completion_fragment_start %{
    execute-keys "h<a-t>%opt{snippets_prefix}"
  }

  # Internal variables
  declare-option -hidden completions snippets_completions
  declare-option -hidden str snippets_completions_header
  declare-option -hidden str-list snippets_completions_body
  declare-option -hidden str snippets_name
  declare-option -hidden str snippets_content
  declare-option -hidden str-list snippets_saved_completers

  # Main interface for snippets completions
  #
  # Populate the completion option with appropriate suggestions.
  #
  # Usage: Call this command in an InsertIdle hook.
  define-command -hidden snippets-set-completions %{
    try %{
      # Test whether the commands contained in the option pass.
      # If not, it will throw an exception and execution will jump to
      # the “catch” block below.
      evaluate-commands -draft -save-regs '/' %opt{snippets_completion_trigger}

      # The selection’s cursor is at the anchor point for completions,
      # and the selection covers the text the completions should replace,
      # exactly the information we need for the header item.
      snippets-build-completions-header %opt{snippets_completion_fragment_start}

      # Now we have built the header item,
      # we can add the actual completions.
      set-option window snippets_completions %opt{snippets_completions_header} %opt{snippets_completions_body}
    } catch %{
      # This is not a place to suggest snippets,
      # so clear our list of completions.
      set-option window snippets_completions
    }
  }

  # Expand selected snippet in the list of completions.
  # Doing <s><empty-snippet-name>\z<ret> will always fail.
  define-command -hidden snippets-expand %{
    evaluate-commands -draft -save-regs '/' %{
      execute-keys 'h<a-h>'
      set-register / "\Q%opt{snippets_prefix}%opt{snippets_name}\E\z"
      execute-keys 's<ret>'
      snippets-replace %opt{snippets_content}
    }
  }

  # Try to expand a snippet.
  define-command -hidden snippets-try-expand %{
    try %{
      evaluate-commands -draft %{
        # Select snippet
        execute-keys "h<a-t>%opt{snippets_prefix}"

        evaluate-commands %sh{
          # Prelude
          . "$kak_opt_prelude_path"

          # Try to get the content of the selected snippet
          content=$(
            snippets get snippet global "$kak_opt_filetype" "$kak_opt_snippets_scope" "$kak_main_reg_dot" |
            jq --exit-status --join-output .content
          )

          # Abort?
          [ $? = 0 ] || exit 1

          # Remove prefix
          kak_escape execute-keys -draft 'hd'
          kak_escape snippets-replace "$content"
        }
      }
    }
  }

  # Expand on enter selected snippet in the list of completions.
  # Accept an additional command on fail.
  #
  # Example:
  # map global insert <ret> '<a-;>: snippets-enter auto-pairs-insert-new-line<ret>'
  define-command -docstring 'Expand snippets on enter when the completion candidate is selected' snippets-enter -params .. %{
    try %{
      snippets-expand
    } catch %{
      evaluate-commands %arg{@}
    } catch %{
      execute-keys -with-hooks '<ret>'
    }
  }

  # Install and deinstall snippets_completions
  define-command -hidden snippets-install-completer %{
    set-option window snippets_saved_completers %opt{completers}
    set-option window completers option=snippets_completions %opt{completers}
  }

  define-command -hidden snippets-remove-completer %{
    set-option window completers %opt{snippets_saved_completers}
  }

  # Build the completions header
  define-command -hidden snippets-build-completions-header -params .. %{
    evaluate-commands -draft %{
      evaluate-commands %arg{@}
      set-option window snippets_completions_header "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    }
  }

  # Build the completions body with the given scopes.
  # Example: crystal crystal/spec
  define-command -hidden snippets-build-completions-body -params .. %{
    nop %sh{
      {
        # Prelude
        . "$kak_opt_prelude_path"

        sh_quoted_snippets_as_tuples=$(snippets get snippets "$@" | jq --sort-keys | jq --raw-output '[.[] | .name, .content] | @sh')

        eval "set -- $sh_quoted_snippets_as_tuples"

        {
          kak_escape_partial set-option "buffer=$kak_bufname" snippets_completions_body
          while [ "$2" ]; do
            # Tuple
            name=$1
            content=$2
            shift 2

            # Memorize the snippet name and content on select.
            # Forget it on InsertCompletionHide.
            select_command=$(
              kak_escape set-option window snippets_name "$name"
              kak_escape set-option window snippets_content "$content"
              kak_escape info "$content"
            )

            # Escape values
            escaped_name=$(printf '%s' "$name" | sed 's/|/\\|/g')
            escaped_select_command=$(printf '%s' "$select_command" | sed 's/|/\\|/g')

            # Candidate completion fields
            text=$escaped_name
            select_command=$escaped_select_command
            menu_text=$escaped_name

            kak_escape_partial "$text|$select_command|$menu_text"
          done
        } | kak -p "$kak_session"
      } < /dev/null > /dev/null 2>&1 &
    }
  }

  define-command -hidden snippets-forget-selected-snippet %{
    set-option window snippets_name ''
    set-option window snippets_content ''
  }

  # Enable and disable snippets
  define-command snippets-enable -docstring 'Enable snippets' %{
    # Mappings
    map global insert <ret> '<a-;>: snippets-enter<ret>'
    map global insert <a-ret> '<a-;>: snippets-try-expand<ret>'

    # Hooks
    hook -group snippets global WinSetOption '(filetype|snippets_scope)=.*' %{
      snippets-build-completions-body global %opt{filetype} %opt{snippets_scope}
    }

    hook -group snippets -always global ModeChange 'push:normal:insert' %{
      snippets-install-completer
    }

    hook -group snippets -always global ModeChange 'pop:insert:normal' %{
      snippets-remove-completer
    }

    hook -group snippets global InsertIdle '.*' %{
      snippets-set-completions
    }

    hook -group snippets global InsertCompletionHide '.*' %{
      snippets-forget-selected-snippet
    }
  }

  define-command snippets-disable -docstring 'Disable snippets' %{
    remove-hooks global snippets
    unmap global insert <ret>
  }

  # Commands to insert snippets
  # Insert text with proper indentation and quickly jump to the next placeholder with phantom.kak.
  define-command -hidden snippets-insert -params 1 %{
    snippets-paste insert %arg{1}
  }

  define-command -hidden snippets-append -params 1 %{
    snippets-paste append %arg{1}
  }

  define-command -hidden snippets-replace -params 1 %{
    snippets-paste replace %arg{1}
  }

  # Paste using the specified method.
  #
  # – insert
  # – append
  # – replace
  define-command -hidden snippets-paste -params 2 %{
    try %{
      evaluate-commands -draft %{
        evaluate-commands -verbatim "snippets-%arg{1}-text" %arg{2}
        set-register / '\{\{.*?\}\}'
        execute-keys 's<ret>'
        phantom-save
      }
    }
  }

  # Utility command to add a scope for a matching path
  # snippets-add-scope <option-scope> <snippets-scope> <buffer-path>
  define-command -hidden snippets-add-scope -params 3 %{
    hook -group snippets-add-scope -always -once window User "snippets-buffer-path=%arg{3}" "
      set-option -add %arg{1} snippets_scope %arg{2}
    "

    trigger-user-hook "snippets-buffer-path=%val{buffile}"

    # Clean hook
    remove-hooks window snippets-add-scope
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
