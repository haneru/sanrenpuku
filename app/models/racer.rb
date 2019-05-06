class Racer < ApplicationRecord

  include Mikazuki

  BASE_URL = 'https://www.boatrace.jp/owpc/pc/data/racersearch'.freeze

  #==== validates
  validates_presence_of %i[win_per
                           two_ren_per
                           three_ren_per
                           first_per
                           third_per
                           fourth_per
                           fifth_per
                           sixth_per
                           first_cource
                           second_cource
                           third_cource
                           fourth_cource
                           fifth_cource
                           sixth_cource]
  validates_uniqueness_of :racer_number

  def collect
    per_url = "#{BASE_URL}/season?toban=#{racer_number}"
    per_data = Mikazuki.get_page(per_url).css('.table1').css('td').to_a

    return unless per_data.present?

    rate_data(per_data)
    cource_data
  end

  def rate_data(per_data)
    per_data = per_data.map { |data| data.text.gsub(/%.*\z/, '').to_f }
    self.win_per = per_data[0]
    self.two_ren_per = per_data[1]
    self.three_ren_per = per_data[2]
    self.first_per = per_data[10]
    self.second_per = per_data[11]
    self.third_per = per_data[12]
    self.fourth_per = per_data[13]
    self.fifth_per = per_data[14]
    self.sixth_per = per_data[15]
  end

  def cource_data
    course_url = "#{BASE_URL}/course?toban=#{racer_number}"
    course_data = (Mikazuki.get_page(course_url)
                           .css('.table1')
                           .css('.is-w400')[1]
                           .css('span')
                           .to_a
                           .map(&:text) - ['']).map { |text| text.gsub(/%/, '').to_f }
    self.first_cource = course_data[0]
    self.second_cource = course_data[1]
    self.third_cource = course_data[2]
    self.fourth_cource = course_data[3]
    self.fifth_cource = course_data[4]
    self.sixth_cource = course_data[5]
  end
end
