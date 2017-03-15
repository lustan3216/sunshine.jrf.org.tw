class Scrap::UploadRefereeContext < BaseContext
  include Scrap::Concerns::AnalysisRefereeContent
  before_perform  :build_content_json
  before_perform  :build_file
  before_perform  :assign_value
  after_perform   :remove_tempfile

  def initialize(orginal_data)
    @orginal_data = orginal_data
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
  end

  def perform(referee)
    @referee = referee
    @type = referee.class.name.downcase
    run_callbacks :perform do
      add_error('upload file failed') unless @referee.save
      true
    end
  rescue
    Logs::AddCrawlerError.send("add_#{@type}_error", @crawler_history, @referee, :upload_file_error, '檔案上傳s3失敗')
  end

  private

  def build_content_json
    @content_data = {}
    data = Nokogiri::HTML(@orginal_data)
    date = data.css('table')[2].css('table')[1].css('span')[1].text[/\d+/]
    @content_data['裁判字號'] = data.css('table')[2].css('table')[1].css('span')[0].text[/\d+,\p{Han}+,\d+/].tr(',', '/')
    @content_data['法院名稱'] = @referee.story.court.full_name
    @content_data['法院代號'] = @referee.story.court.code
    @content_data['案由'] = data.css('table')[2].css('table')[1].css('span')[2].text[/(?<=\u00a0)\p{Han}+/]
    @content_data['民國年'] = date[0..-5]
    @content_data['西元年'] = (date[0..-5].to_i + 1911).to_s
    @content_data['月'] = date[-4..-3].to_i.to_s
    @content_data['日'] = date[-2..-1].to_i.to_s
    @content_data['法官姓名'] = @referee.judges_names
    @content_data['律師姓名'] = @referee.lawyer_names
    @content_data['被告姓名'] = @referee.party_names
    @content_data['內文'] = data.css('table')[2].css('table')[1].css('pre')[0].text
    @role_hash = parse_roles_hash(@referee, data.text, @crawler_history)
    @content_data = @content_data.merge(@role_hash)
  end

  def build_file
    @file = generate_tempfile(@orginal_data, 'referee', 'html')
    @content_file = generate_tempfile(@content_data, @referee.story.identity, 'json')
  end

  def generate_tempfile(data, file_name, file_type)
    file = Tempfile.new([file_name, ".#{file_type}"], "#{Rails.root}/tmp/")
    file.write(data)
    file.rewind
    file.close
    file
  end

  def assign_value
    @referee.assign_attributes(file: File.open(@file.path), content_file: File.open(@content_file.path), crawl_data: @role_hash)
  end

  def remove_tempfile
    @file.unlink
    @content_file.unlink
  end
end