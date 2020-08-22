# Ruby on Rails
# https://rubyonrails.org

provide-module snippets-rails %{
  hook -group snippets-rails global WinSetOption 'filetype=(ruby|eruby|html|css|scss|javascript)' %{
    # Filetype
    set-option -add window snippets_scope "rails/%opt{filetype}"

    # Gemfile
    snippets-add-scope window rails/ruby/gemfile '/.+/Gemfile'

    # MVC
    snippets-add-scope window rails/ruby/model '/.+/app/models/.+\.rb'
    snippets-add-scope window rails/ruby/view '/.+/app/views/.+\.erb'
    snippets-add-scope window rails/ruby/controller '/.+/app/controllers/.+\.rb'

    # Routes
    snippets-add-scope window rails/ruby/routes '/.+/config/routes\.rb'

    # Database
    snippets-add-scope window rails/ruby/migration '/.+/db/migrate/.+\.rb'
    snippets-add-scope window rails/ruby/db/seed '/.+/db/seeds\.rb'

    # Wiki
    snippets-add-scope window rails/wiki '\*scratch\*'

    # Clean options
    hook -always -once window WinSetOption 'filetype=.*' %{
      unset-option window snippets_scope
    }
  }
}
