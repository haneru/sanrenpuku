class ResultsController < ApplicationController
 def index; end

 def new
   @result = Result.new
 end

 def create
   @result = Result.new(result_params)
   return render :new if result_params[:collect_date] == ''
   uri = "https://www.boatrace.jp/owpc/pc/race/index?hd=#{result_params[:collect_date].to_time.strftime('%Y%m%d')}"
   @page = Result.page(uri)
   field_names = @page.css('body').css('tbody').css('td.is-arrow1.is-fBold.is-fs15').map(&:children).map(&:children).map(&:to_a).map(&:first).map(&:attributes).map{|td| td['alt'].text.gsub(/\>/, '') }
   @fields = Field.where(name: field_names)
 end

 def result
   @result = Result.new(result_params)
   @field = Field.find_by(id: @result.field_id)

   nums = %w[1 2 3 4 5 6]
   arr = []
   race_num_string = '?rno=' + @result.race_number.to_s
   field_code_string = '&jcd=' + sprintf("%02d", Field.find_by_id(@result.field_id.to_i).code)
   collect_date_string = '&hd=' + @result.collect_date.to_time.strftime('%Y%m%d')
   url = 'https://www.boatrace.jp/owpc/pc/race/racelist' + race_num_string + field_code_string + collect_date_string

   data = page(url).css('.table1').css('tbody.is-fs12').css('.is-lineH2').to_s.split(/\n/).map{|s| s.split(/\p{blank}/) - ['']}.each_slice(20).to_a.map(&:flatten)
   hash_data = nums.zip(data).to_h
   1.upto(6) do |i|
     test = []
     test << hash_data[i.to_s][10].strip.delete('<br>').to_f
     test << hash_data[i.to_s][11].strip.delete('<br>').to_f
     # test << hash_data[i.to_s][16].strip.delete('<br>').to_f unless hash_data[i.to_s][16].strip.delete('<br>').to_f.zero?
     # test << hash_data[i.to_s][17].strip.delete('<br>').to_f
     #test << hash_data[i.to_s][23].strip.delete('<br>').to_f
     test << hash_data[i.to_s][24].strip.delete('<br>').to_f
     #test << hash_data[i.to_s][30].strip.delete('<br>').to_f
     test << hash_data[i.to_s][31].strip.delete('<br>').to_f
     arr << (test.inject(&:+) / test.count)
   end
   test_data = nums.zip(arr).to_h
   test_data

   link_arr = []

   1.upto(6) do |i|
     link_arr << 'https://www.boatrace.jp' + page(url).css('.is-fs18.is-fBold').css('a')[i - 1].values.first.gsub(/profile/, 'course')
   end

   course_arr = []

   link_arr.each_with_index do |link, i|
     i += 1
     test = page(link).css('.is-w400').css('tbody').css('tr.is-p5-0').css('.table1_progress2').css('span.table1_progress2Label').to_a[i + 17].text.to_f
     course_arr << page(link).css('table.is-w400').css('tbody').css('span.table1_progress2Label').to_a[i + 5].children.to_s.gsub(/%/, '').to_f * (3/test.to_f)
   end

   sum = test_data.values.zip(course_arr).map{|n,p| (n+p) / 2}

   @results = nums.zip(sum).to_h.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
   all = @results.map { |_key, value| value }.inject(:+)
   @results = @results.map{ |key, value| [key, ((value / all) * 100).ceil(1)] }
 end

 private

 def result_params
   params.require(:result).permit(:collect_date, :race_number, :field_id)
 end


 def page(url)
   opt = {}
   opt['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv 11.0) like Gecko'
   Nokogiri::HTML.parse(open(url, opt).read)
 end
end
