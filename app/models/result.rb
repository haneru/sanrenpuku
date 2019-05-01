class Result < ApplicationRecord
  require 'nokogiri'
  require 'open-uri'

  belongs_to :field
  validates_presence_of :collect_date

  attr_accessor :collect_date, :field_id, :race_number

  class << self
    def page(uri)
      opt = {}
      opt['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv 11.0) like Gecko'
      Nokogiri::HTML.parse(open(uri, opt).read)
    end
  end
end
