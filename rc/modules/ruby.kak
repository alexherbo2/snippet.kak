# Ruby
# https://ruby-lang.org

provide-module snippets-ruby %{
  hook -group snippets-ruby global WinSetOption 'filetype=ruby' %{
    # RSpec
    # https://rspec.info
    snippets-add-scope window ruby/spec '/.+/spec/.+_spec\.rb'

    # Clean options
    hook -always -once window WinSetOption 'filetype=.*' %{
      unset-option window snippets_scope
    }
  }
}
