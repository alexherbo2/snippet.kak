declare-option -docstring 'List of – {key} {value} – snippets' str-list snippets
declare-option -docstring 'Information about the way snippets are active' bool snippets_enabled no

define-command snippets-enable -docstring 'Enable snippets' %{
  hook window InsertChar \n -group snippets %{ evaluate-commands -draft -save-regs '' %{
    execute-keys h
    evaluate-commands %sh{
      eval "set -- $kak_opt_snippets"
      while test $# -ge 2; do
        key=$1
        value=$2
        shift 2
        echo "
          set-register k '$key'
          set-register v '$value'
          try %{
            execute-keys -draft \"${#key}H<a-;>H<a-k>\A\Q%reg(k)\E\z<ret>c<del>\"
            execute-keys -client %val(client) -save-regs '' %reg(v)
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
