I was trying & failing to install my `jekyll` environment on my `MacOS` laptop via `bundle` ...

```sh
❯ bundle install
Fetching gem metadata from https://rubygems.org/.........
Installing bigdecimal 3.1.4 with native extensions
Installing http_parser.rb 0.8.0 with native extensions
Installing eventmachine 1.2.7 with native extensions
Installing ffi 1.16.3 with native extensions
Installing racc 1.7.3 with native extensions
Bundle complete! 8 Gemfile dependencies, 47 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
❯ bundle exec jekyll serve
Could not find eventmachine-1.2.7, http_parser.rb-0.8.0, bigdecimal-3.1.4, racc-1.7.3, ffi-1.16.3 in locally installed gems
Run `bundle install` to install missing gems.
```

So I ran `gem list` & I could see that `bigdecimal` etc were ignored ...

So I found [Ignoring GEM because its extensions are not built](https://stackoverflow.com/questions/38797458/ignoring-gem-because-its-extensions-are-not-built) & tried `gem pristine --all` I could see that `/usr/bin/ruby` was conflicting with `ruby` installed via `nix` since I installed `bundle` directly rather than `ruby` so `ruby` is not registered on my `PATH` ...

So I installed `ruby` directly.  Then  I set `bundle config set --global path "$HOME/.bundle/"`

#ruby
#jekyll
