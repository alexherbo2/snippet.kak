# Crystal
# https://crystal-lang.org

provide-module snippets-crystal %{
  hook -group snippets-crystal global WinSetOption 'filetype=crystal' %{
    # Spec
    snippets-add-scope window crystal/spec '/.+/spec/.+_spec\.cr'

    # Clean options
    hook -always -once window WinSetOption 'filetype=.*' %{
      unset-option window snippets_scope
    }
  }
}
