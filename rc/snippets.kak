declare-option -docstring 'JSON-formatted string of snippets' str snippets {}
declare-option -docstring 'Information about the way snippets are active' bool snippets_enabled no

define-command snippets-enable -docstring 'Enable snippets' %{
  hook window InsertChar \n -group snippets %{ evaluate-commands -draft -save-regs '' %{
    execute-keys h
    %sh{
      echo "$kak_opt_snippets" | jq --raw-output 'to_entries | .[] | @sh "
        set-register k \(.key)
        set-register v \(.value)
        try %{
          execute-keys -draft \"\(.key | length)H<a-;>H<a-k>\\A%reg(k)\\z<ret>c<del>\"
          execute-keys -client %val(client) -save-regs %[] %reg(v)
        }
      "'
    }
  }}
}

define-command snippets-disable -docstring 'Disable snippets' %{
  remove-hooks window snippets
  set-option window snippets_enabled no
}

define-command snippets-toggle -docstring 'Toggle snippets' %{ %sh{
  if [ "$kak_opt_snippets_enabled" = true ]; then
    echo snippets-disable
  else
    echo snippets-enable
  fi
}}
