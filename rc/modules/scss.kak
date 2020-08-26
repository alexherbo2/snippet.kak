# SCSS
# https://sass-lang.com

provide-module snippets-scss %{
  hook -group snippets-scss global WinSetOption 'filetype=scss' %{
    set-option -add window snippets_scope css

    # Clean options
    hook -always -once window WinSetOption 'filetype=.*' %{
      unset-option window snippets_scope
    }
  }
}
