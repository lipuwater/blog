module Jekyll
  class AuthorPage < Page
    def initialize(site, base, dir, author)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'author_index.html')
      data['author'] = author

      author_title_prefix = site.config['author_title_prefix'] || 'Author: '
      data['title'] = "#{author_title_prefix}#{author}"
    end
  end

  class AuthorPageGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'author_index'
        dir = site.config['author_dir'] || 'authors'
        site.data['authors'].each_key do |author|
          site.pages << AuthorPage.new(site, site.source, File.join(dir, author), author)
        end
      end
    end
  end
end
