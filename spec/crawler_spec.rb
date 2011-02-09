require File.dirname(__FILE__) + '/spec_helper'
require 'ap'

module StaticGenerator
  describe Crawler do
    before(:each) do
      @options = {
        :destination_path => File.expand_path('spec/destination_directory'),
        :url_prefix => 'http://www.example.com/'
      }
    end

    after(:each) do
      FileUtils.rm_rf(Dir.glob(File.expand_path('spec/destination_directory')+File::SEPARATOR+'*'))
    end

    context 'crawling' do

      it 'should find a page that links to another pages' do
        pages = []
        pages << FakePage.new('0', :links => '1')
        pages << FakePage.new('1')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!

        @crawler.pages.size.should == 2
      end

      it 'should find a page that links to two other pages' do
        pages = []
        pages << FakePage.new('0', :links => ['1','2'])
        pages << FakePage.new('1')
        pages << FakePage.new('2')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!

        @crawler.pages.size.should == 3
      end

      it 'should have the right prefix for the given url' do
        @crawler = Crawler.new(FakePage.new('home').url, @options)
        @crawler.crawl!
        @crawler.pages[0].short_path.should == 'home'

        pages = []
        pages << FakePage.new('0', :links => ['0/1'])
        pages << FakePage.new('0/1')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!
        @crawler.pages[1].short_path.should == '0/1'

        pages = []
        pages << FakePage.new('root', :links => ['root/subpage/subsubpage'])
        pages << FakePage.new('root/subpage/subsubpage')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!
        @crawler.pages[1].short_path.should == 'root/subpage/subsubpage'

        # ensure we have a / at the end
        lambda { 
          @crawler = Crawler.new(FakePage.new('root').url, @options.merge({:url_prefix => 'http://www.example.com'}))
        }.should raise_error WrongURLPrefixError
      end

      it 'should follow a relative link' do
        pages = []
        pages << FakePage.new('home', :hrefs => ['/subpage', 'otherpage'])
        pages << FakePage.new('subpage')
        pages << FakePage.new('otherpage')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!
        @crawler.pages[0].short_path.should == 'home'
        @crawler.pages[1].short_path.should == 'subpage'
        @crawler.pages[2].short_path.should == 'otherpage'
        @crawler.pages[2].crawled_page.url.to_s.should == 'http://www.example.com/otherpage'
      end
    end

    context 'folder' do
      it 'should not be created if destination_path does not exist' do
        lambda {
          @crawler = Crawler.new(FakePage.new('home').url, @options.merge({
            :destination_path=>File.expand_path('spec/destination_directory/')+File::SEPARATOR+'folder_that_doesnt_exist'
          }))
        }.should raise_error DestinationPathDoesNotExist
      end

      it 'should be created' do
        @crawler = Crawler.new(FakePage.new('home').url, @options)        
        @crawler.crawl!
        File.exists?(File.expand_path('spec/destination_directory/')+File::SEPARATOR+'home').should == true
      end

      it 'should have an index.html file in it' do
        @crawler = Crawler.new(FakePage.new('home').url, @options)        
        @crawler.crawl!
        File.exists?(File.expand_path('spec/destination_directory/')+File::SEPARATOR+'home'+File::SEPARATOR+'index.html').should == true
      end

      it 'should throw an error if is not writable' do
        lambda {
          @crawler = Crawler.new(FakePage.new('home').url, @options.merge({
            :destination_path=>File.expand_path('spec/non_writable/')
          }))
        }.should raise_error DestinationPathNotWritableError
      end
    end

    context 'folder with a sub folder in it' do

      it 'should be created' do
        pages = []
        pages << FakePage.new('folder', :links => ['folder/subfolder'])
        pages << FakePage.new('folder/subfolder')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!
        File.exists?(File.expand_path('spec/destination_directory/')+File::SEPARATOR+'folder'+File::SEPARATOR+'subfolder').should == true
      end

      it 'should have an index.html file in it' do
        pages = []
        pages << FakePage.new('folder', :links => ['folder/subfolder'])
        pages << FakePage.new('folder/subfolder')
        @crawler = Crawler.new(pages[0].url, @options)
        @crawler.crawl!
        File.exists?(File.expand_path('spec/destination_directory/')+File::SEPARATOR+'folder'+File::SEPARATOR+'subfolder'+File::SEPARATOR+'index.html').should == true
      end
    end

  end
end
