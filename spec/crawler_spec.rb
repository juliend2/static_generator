require File.dirname(__FILE__) + '/spec_helper'
require 'ap'

module StaticGenerator
  describe Crawler do
    context 'crawling' do

      before(:each) do
        @options = {
          :destination_path => File.expand_path('spec/destination_directory/'),
          :url_prefix => 'http://www.example.com/'
        }
      end

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
        }.should raise_error
      end
    end

    context 'creating folders' do
      before(:each) do
        @options = {
          :destination_path => File.expand_path('spec/destination_directory'),
          :url_prefix => 'http://www.example.com/'
        }
      end

      it 'should not create a base folder if it does not exist' do
        lambda {
          @crawler = Crawler.new(FakePage.new('home').url, @options.merge({
            :destination_path=>File.expand_path('spec/destination_directory/')+File::SEPARATOR+'folder_that_doesnt_exist'
          }))
        }.should raise_error
      end

      #it 'should create one file' do
      #  @crawler = Crawler.new(FakePage.new('home').url, @options)
      #  @crawler.crawl!

      #  
      #end
    end

  end
end
