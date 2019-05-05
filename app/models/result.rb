class Result < ApplicationRecord
  include Mikazuki

  # relations
  belongs_to :field

  # validates
  validates_presence_of :collect_date,
                        :field_id,
                        :race_number

  validates_inclusion_of :race_number, in: 1..12

  validate :unique_race, on: :create

  def ranking
    {
      1 => first_cource,
      2 => second_cource,
      3 => third_cource,
      4 => fourth_cource,
      5 => fifth_cource,
      6 => sixth_cource
    }.sort { |(_key_1, val_1), (_key_2, val_2)| val_2 <=> val_1 }
  end

  def unique_race
    if Result.where(collect_date: collect_date,
                 field_id: field_id,
                 race_number: race_number)
             .present?
      errors.add(:error, ": 既に集計されたレースです。")
    end
  end

  def collect_race_win_per
    nums = %w[1 2 3 4 5 6]
    arr = []
    race_num_string = '?rno=' + race_number.to_s
    field_code_string = '&jcd=' + sprintf('%02d', Field.find_by_id(field_id.to_i).code)
    collect_date_string = '&hd=' + collect_date.to_time.strftime('%Y%m%d')
    url = 'https://www.boatrace.jp/owpc/pc/race/racelist' + race_num_string + field_code_string + collect_date_string

    data = Mikazuki.get_page(url)
                   .css('.table1')
                   .css('tbody.is-fs12')
                   .css('.is-lineH2')
                   .to_s
                   .split(/\n/)
                   .map { |s| s.split(/\p{blank}/) - [''] }
                   .each_slice(20).to_a.map(&:flatten)
    hash_data = nums.zip(data).to_h
    1.upto(6) do |i|
      test = []
      test << hash_data[i.to_s][10].strip.delete('<br>').to_f
      test << hash_data[i.to_s][11].strip.delete('<br>').to_f
      test << hash_data[i.to_s][16].strip.delete('<br>').to_f unless hash_data[i.to_s][16].strip.delete('<br>').to_f.zero?
      test << hash_data[i.to_s][17].strip.delete('<br>').to_f
      test << hash_data[i.to_s][23].strip.delete('<br>').to_f
      test << hash_data[i.to_s][24].strip.delete('<br>').to_f
      test << hash_data[i.to_s][30].strip.delete('<br>').to_f
      test << hash_data[i.to_s][31].strip.delete('<br>').to_f
      arr << (test.inject(&:+) / test.count)
    end
    test_data = nums.zip(arr).to_h

    link_arr = []

    1.upto(6) do |i|
      link_arr << 'https://www.boatrace.jp' + Mikazuki.get_page(url).css('.is-fs18.is-fBold').css('a')[i - 1].values.first.gsub(/profile/, 'course')
    end

    course_arr = []

    link_arr.each_with_index do |link, i|
      i += 1
      test = Mikazuki.get_page(link)
                     .css('.is-w400')
                     .css('tbody')
                     .css('tr.is-p5-0')
                     .css('.table1_progress2')
                     .css('span.table1_progress2Label')
                     .to_a[i + 17]
                     .text
                     .to_f

      test = test.zero? ? 0 : 3 / test.to_f
      course_arr << Mikazuki.get_page(link).css('table.is-w400').css('tbody').css('span.table1_progress2Label').to_a[i + 5].children.to_s.gsub(/%/, '').to_f * test
    end

    sum = test_data.values.zip(course_arr).map{ |n, p| (n + p) / 2 }

    results = nums.zip(sum).to_h
    all = results.map { |_key, value| value }.inject(:+)
    results = results.map { |key, value| [key, ((value / all) * 100).ceil(1)] }
    self.first_cource = results[0][1]
    self.second_cource = results[1][1]
    self.third_cource = results[2][1]
    self.fourth_cource = results[3][1]
    self.fifth_cource = results[4][1]
    self.sixth_cource = results[5][1]
  end
end
