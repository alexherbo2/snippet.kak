declare-option -docstring 'List of – {snippet} {expansion} – snippets' str-list snippets
declare-option -docstring 'Information about the way snippets are active' bool snippets_enabled no

define-command snippets-enable -docstring 'Enable snippets' %{
  hook window InsertChar \n -group snippets %{ evaluate-commands -draft %{
    execute-keys h
    evaluate-commands %sh{
      eval "set -- $kak_opt_snippets"
      while test $# -ge 2; do
        snippet=$1
        expansion=$2
        shift 2
        echo "
          try %{
            execute-keys -draft %(${#snippet}H<a-;>H<a-k>\A\Q$snippet\E\z<ret>c<del>)
            execute-keys -client %val(client) -with-hooks -save-regs '' %($expansion)
          }
        "
      done
    }
  }}
}

define-command snippets-disable -docstring 'Disable snippets' %{
  remove-hooks window snippets
  set-option window snippets_enabled no
}

define-command snippets-toggle -docstring 'Toggle snippets' %{ evaluate-commands %sh{
  if [ "$kak_opt_snippets_enabled" = true ]; then
    echo snippets-disable
  else
    echo snippets-enable
  fi
}}
