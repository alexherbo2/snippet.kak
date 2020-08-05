# Snippets paths
declare-option -hidden str snippets_plugin_path %sh(dirname "$kak_source")
declare-option -hidden str snippets_root_path %sh(dirname "$kak_opt_snippets_plugin_path")
declare-option -hidden str snippets_path "%opt{snippets_root_path}/snippets"

hook global ModuleLoaded snippets %{
  snippets-enable
}

provide-module snippets %{

  # Modules ────────────────────────────────────────────────────────────────────

  require-module prelude

  # Options ────────────────────────────────────────────────────────────────────

  # Snippets directories:
  # – ~/.config/kak/snippets
  # – /path/to/snippets.kak/snippets
  declare-option -docstring 'List of snippets directories' str-list snippets_directories "%val{config}/snippets" %opt{snippets_path}
  # Regex placeholder:
  # def {name}
  # 	{body}
  # end
  declare-option -docstring 'Regex to select snippet placeholders' str snippets_placeholder '\{[\w-]*\}'
  # Cache
  declare-option -docstring 'Path to snippets cache' str snippets_cache_path %sh{
    # Environment variables
    XDG_CACHE_HOME=${XDG_CACHE_HOME:-~/.cache}
    CACHE=$XDG_CACHE_HOME/kak/snippets
    printf '%s' "$CACHE"
  }
  # Completion
  declare-option -hidden str-list snippets_candidates
  declare-option -hidden str snippets_completion %{
    eval "set -- $kak_quoted_opt_snippets_candidates"
    printf '%s\n' "$@"
  }
  # Save registers
  declare-option -hidden str-list snippets_mark_register
  declare-option -hidden str-list snippets_search_register
  # Determines whether snippets are active
  declare-option -hidden bool snippets_active

  # Commands ───────────────────────────────────────────────────────────────────

  define-command snippets-enable -docstring 'Enable snippets' %{
    map global insert <a-ret> '<a-;>: snippets-menu<ret>/' -docstring 'Menu for snippets'
    hook -group snippets-build global WinSetOption filetype=.* %{
      snippets-build
    }
  }

  define-command snippets-disable -docstring 'Disable snippets' %{
    unmap global insert <a-ret>
    remove-hooks global snippets-build
  }

  define-command snippets-menu -docstring 'Menu for snippets' %{
    evaluate-commands "snippets-%opt{filetype}-menu"
  }

  define-command snippets-insert -params 1.. -shell-script-candidates %opt{snippets_completion} -docstring 'Insert snippets' %{
    snippets-implement "%arg{@}"
  }

  # Implementation ─────────────────────────────────────────────────────────────

  define-command -hidden snippets-build %{
    # Build the menu and completion asynchronously
    nop %sh{
      {
        # Prelude
        . "$kak_opt_prelude"

        # Abort if no filetype
        if test -z "$kak_opt_filetype"; then
          exit 1
        fi

        # Cache
        cache_path=$kak_opt_snippets_cache_path/$kak_opt_filetype
        mkdir -p "$cache_path"

        # Menu
        menu=$(
          # Declaration
          kak_escape_partial menu -select-cmds --

          # Sort snippets
          {
            eval "set -- $kak_quoted_opt_snippets_directories"
            for directory do
              find -L "$directory/$kak_opt_filetype" "$directory/global" -type f
            done
          } | sort |
          while read snippet_path; do
            # Paths
            snippet_directory=${snippet_path%/*}
            snippet_name=${snippet_path##*/}

            # Content
            content=$(cat "$snippet_path")

            # Name
            kak_escape_partial "$snippet_name"

            # Command
            menu_command=$(
              kak_escape snippets-implement "$content"
            )
            kak_escape_partial "$menu_command"

            # Information
            menu_info=$(
              kak_escape info "$content"
            )
            kak_escape_partial "$menu_info"

            # Update cache
            ln -sf "$snippet_path" "$cache_path"
          done
        )
        # The menu has been built asynchronously
        kak_escape define-command -hidden -override "snippets-${kak_opt_filetype}-menu" "$menu" |
        kak -p "$kak_session"

        # Completion
        {
          kak_escape_partial set-option "buffer=$kak_bufname" snippets_candidates
          find -L "$cache_path" -type f | sort |
          while read snippet_path; do
            # Paths
            snippet_name=${snippet_path##*/}

            kak_escape_partial "{{$snippet_name}}"
          done
        } |
        kak -p "$kak_session"
      } < /dev/null > /dev/null 2>&1 &
    }
  }

  define-command -hidden snippets-implement -params 1 %{
    evaluate-commands -draft %{
      # Workaround the smartness of the paste commands by using the replace command.
      execute-keys ';iX<left><esc>'
      snippets-replace-text %arg{1}
      # Sub-snippets
      try %{
        evaluate-commands -draft %{
          snippets-search-and-expand
        }
      }
      # Once activated, snippets are active until all placeholders have been consumed.
      try %{
        evaluate-commands %sh{
          if test "$kak_opt_snippets_active" = true; then
            printf fail
          fi
        }
        set-option window snippets_active true
        # Save registers
        set-option window snippets_mark_register %reg{^}
        set-option window snippets_search_register %reg{/}
        # Save regions and set the search register for selecting placeholders
        execute-keys -save-regs '' Z
        set-register / %opt{snippets_placeholder}
        # Mappings for the whole insert session
        map window insert <a-n> '<a-;>: snippets-select-next-placeholder<ret>' -docstring 'Select the next placeholder'
        map window insert <a-p> '<a-;>: snippets-select-previous-placeholder<ret>' -docstring 'Select the previous placeholder'
        # Deactivate when no placeholder remains in saved regions.
        # Test when leaving insert mode.
        hook -group snippets-active window ModeChange pop:insert:normal %{
          try %{
            # Test if a placeholder matches in saved regions
            execute-keys -draft 'z<a-k><ret>'
          } catch %{
            # If not:
            # Restore registers
            set-register ^ %opt{snippets_mark_register}
            set-register / %opt{snippets_search_register}
            # Unmap
            unmap window insert <a-n>
            unmap window insert <a-p>
            # Deactivate
            unset-option window snippets_active
            remove-hooks window snippets-active
          }
        }
      }
    }
  }

  # Recursively search and expand snippets
  define-command -hidden snippets-search-and-expand %{
    evaluate-commands -save-regs '/' %{
      set-register / '\{\{[\w-]*\}\}'
      execute-keys 's<ret>i<del><del><esc>a<backspace><backspace><esc>'
      evaluate-commands -itersel %{
        snippets-replace-from-file "%opt{snippets_cache_path}/%opt{filetype}/%val{main_reg_dot}"
      }
    }
    snippets-search-and-expand
  }

  define-command -hidden snippets-select-next-placeholder %{
    snippets-select-placeholder ')'
  }

  define-command -hidden snippets-select-previous-placeholder %{
    snippets-select-placeholder '<esc>'
  }

  # Belongs to the snippets-implement command.
  # The command is executed from a mapping in insert mode.
  # We reuse the mark and search registers set by snippets-implement.
  define-command -hidden snippets-select-placeholder -params 1 %{
    try %{
      # Test if saved regions contain a placeholder before modifying selections
      execute-keys -draft 'z<a-k><ret>'
      execute-keys '<a-;>z'
      evaluate-commands -itersel %{
        execute-keys "<a-;>s<ret><a-;>%arg{1}<a-;><space><a-;>d"
      }
    }
  }

  # Generics ───────────────────────────────────────────────────────────────────

  # Commands to insert text
  define-command -hidden snippets-replace-text -params 1 %{
    snippets-paste-text 'R' %arg{1}
  }

  define-command -hidden snippets-insert-text -params 1 %{
    snippets-paste-text '<a-P>' %arg{1}
  }

  define-command -hidden snippets-append-text -params 1 %{
    snippets-paste-text '<a-p>' %arg{1}
  }

  # Commands to insert text from file
  define-command -hidden snippets-replace-from-file -params 1 %{
    evaluate-commands snippets-replace-text "%%file{%arg{1}}"
  }

  define-command -hidden snippets-insert-from-file -params 1 %{
    evaluate-commands snippets-insert-text "%%file{%arg{1}}"
  }

  define-command -hidden snippets-append-from-file -params 1 %{
    evaluate-commands snippets-append-text "%%file{%arg{1}}"
  }

  # Command implementation
  define-command -hidden snippets-paste-text -params 2 %{
    evaluate-commands -save-regs '"' %{
      # Paste using the specified method
      # The command (R, <a-P> and <a-p>) selects inserted text
      set-register '"' %arg{2}
      execute-keys %arg{1}
      # Remove EOF newline
      try %{
        execute-keys -draft 's\n\z<ret>d'
      }
      # Replace leading tabs with the appropriate indent
      try %{
        evaluate-commands %sh{
          if test "$kak_opt_indentwidth" -eq 0; then
            printf fail
          fi
        }
        execute-keys -draft "<a-s>s\A\t+<ret>s.<ret>%opt{indentwidth}@"
      }
      # Align everything with the current line
      evaluate-commands -draft -itersel %{
        try %{
          execute-keys '<a-s>Z)<space><a-x>s^\h+<ret>yz)<a-space>_P'
        }
      }
    }
  }
}

require-module snippets
