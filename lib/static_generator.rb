require 'anemone'
require 'fileutils'

module StaticGenerator
  
  class WrongURLPrefixError < ArgumentError
  end

  class DestinationPathDoesNotExist < ArgumentError
  end

  class DestinationPathNotWritableError < ArgumentError
  end

  class Page

    attr_reader :crawled_page

    def initialize(crawled_page, url_prefix)
      @crawled_page = crawled_page # from anemone
      @url_prefix = url_prefix
    end

    def short_path
      @crawled_page.url.to_s[@url_prefix.length, @crawled_page.url.to_s.length]
    end

    def body
      @crawled_page.body
    end
  end

  class Crawler

    attr_reader :pages, :destination_path, :url_prefix

    def initialize(opts)
      @destination_path = opts[:destination_path]
      @url_prefix = opts[:url_prefix]
      @url = opts[:url]
      if @url_prefix.nil? 
        raise WrongURLPrefixError, "Expected an `url_prefix` option for the given URL."
      elsif @url !~ /^#{@url_prefix}/
        raise WrongURLPrefixError, "Expected the `url_prefix` option to exist in the given URL."
      elsif @url_prefix[-1, 1] != '/'
        raise WrongURLPrefixError, "Expected the `url_prefix` to end with a '/'."
      end

      if ! File.directory? @destination_path
        raise DestinationPathDoesNotExist
      elsif ! File.writable? @destination_path
        raise DestinationPathNotWritableError
      end
    end

    def crawl!
      @pages = []
      Anemone.crawl(@url) do |anemone|
        anemone.on_every_page do |page|
          @pages << Page.new(page, @url_prefix)
        end
      end
      
      generate_folders
    end

    def generate_folders
      @pages.each{|page| 
        directory = File.expand_path(@destination_path)+File::SEPARATOR+(page.short_path.split('/').join(File::SEPARATOR))
        FileUtils.mkdir_p( directory )
        File.open("#{directory}/index.html", 'w') {|f| f.write(page.body) }
      }
    end
  end

end
