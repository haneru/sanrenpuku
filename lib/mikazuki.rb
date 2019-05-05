module Mikazuki
  require 'pry'
  require 'csv'
  require 'nokogiri'
  require 'time'
  require 'open-uri'
  require 'net/https'
  require 'fileutils'

  #==== UserAgent
  AGENTS = [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10240',
    'Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko',
    'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko'
  ].freeze.map(&:freeze)


  # ====== スクレイピングで時間間隔調整するためのスリープ
  def self.rand_sleep(second)
    puts '==============='
    random = Random.new
    sleep(random.rand(10..20.0) + second)
  end

  # ===== ランダムでUserAgentを返す
  def self.rand_user_agent
    AGENTS.sample
  end

  # 日本語を含むurlだった時、エンコード
  def self.encode_japanese(url)
    if url.match?(/[亜-熙ぁ-んァ-ヶ]/)
      URI.encode(url)
    else
      url
    end
  end

  # ====== スクレイピング用メソッド
  # GET
  def self.get_page(url, param_hash = {})
    opt = {}
    opt['User-Agent'] = Mikazuki.rand_user_agent
    opt[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE
    unless param_hash == {} && url.include?('?')
      url += param_hash.map { |param| param.join('=') }.join('&').insert(0, '?')
    end
    url = Mikazuki.encode_japanese(url)
    Nokogiri::HTML.parse(open(url, opt).read)
  end

  # POST
  def self.post_page(url, param_hash)
    url = Mikazuki.encode_japanese(url)
    # urlの指定
    uri = URI.parse(url)

    # httpの設定
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.path)

    req['user-agent'] = Mikazuki.rand_user_agent

    # postのパラメータの指定
    req.set_form_data(param_hash)

    # リクエスト実行,レスポンス取得
    res = http.request(req)

    Nokogiri::HTML.parse(res.body)
  end

  # ====== ファイルをutf-8bomに変換
  def self.insert_bom(input_filename, output_filename)
    src = File.read(input_filename)
    File.open(output_filename, 'w:UTF-8') do |f|
      src = '   ' + src
      src.setbyte(0, 0xEF)
      src.setbyte(1, 0xBB)
      src.setbyte(2, 0xBF)
      f.print src
    end
    FileUtils.rm(input_filename) # =====元ファイルの削除
  end

  # ====== utf-8bomのcsvファイルを読み込む
  def self.create_data_imported_bom(file_name)
    i = 0
    csv_datas = []
    CSV.foreach(file_name, encoding: 'bom|utf-8', headers: true) do |data|
      i += 1
      csv_datas << { i => Hash[*(data.to_a.flatten)] }
    end
    csv_datas
  end

  def self.export_csv(file_name, datas, options={})
    headers = options[:headers]
    CSV.open(file_name, 'w:UTF-8') do |csv|
      csv << headers unless headers.nil? || headers == ''
      datas.each do |data|
        csv << data
      end
    end
  end

  def self.export_csv_bom(file_name, genre_name, datas, options={})
    self.export_csv(file_name, datas, options)
    self.insert_bom(file_name, "#{genre_name}_#{Time.now.strftime('%Y%m%d')}.csv")
  end
end
