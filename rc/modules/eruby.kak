# eRuby
# https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html

provide-module snippets-eruby %{
  hook -group snippets-eruby global WinSetOption 'filetype=eruby' %{
    set-option -add window snippets_scope html

    # Clean options
    hook -always -once window WinSetOption 'filetype=.*' %{
      unset-option window snippets_scope
    }
  }
}
