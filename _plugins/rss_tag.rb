# _plugins/rss_tag.rb

module Jekyll
  class TagAtom < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = "feed.xml"

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'atom.html')
      data['tag'] = tag
    end
  end

  class TagPageGenerator < Generator
    safe true

    # Generate tag page and atom feed for each tag used in the blogs
    def generate(site)
      # if site.layouts.key? 'tagpage'
        site.tags.each_key do |tag|
          site.pages << TagAtom.new(site, site.source, File.join('tag',tag), tag)
        end
      # end
    end
  end
end
