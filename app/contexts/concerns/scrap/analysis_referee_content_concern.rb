module Scrap::AnalysisRefereeContentConcern
  extend ActiveSupport::Concern

  MAIN_JUDGE = /審判長法\s*官\s*([\p{Word}\w\s]*?)\n/
  JUDGE = /法\s*官[^\r\n]\s+([\p{Word}\w\s]*?)\n/
  PROSECUTOR = /檢察官(\p{Word}+)到庭執行職務/
  LAWYER = /\s+(\p{Word}+)律師/
  HAS_JUDGES = /法官/
  HAS_PROSECUTOR = /檢察官/
  HAS_LAWYER = /律師/
  MAIN_ROLE = PartyNamePatterns.main_role
  SUB_ROLE = PartyNamePatterns.sub_role
  PARSE_ROLES_PATTERN = /(#{MAIN_ROLE.join('|')}){1}[\s]*(#{SUB_ROLE.join('|')})?(\s+\p{han}+[^\r\n]+)((\r\n\s+\p{han}?\s?\p{han}+[^\r\n]+)*)/
  HOST_URI = 'http://jirs.judicial.gov.tw/FJUD/'.freeze
  def parse_main_judge_name(referee, content, crawler_history)
    content = content.tr('　', ' ')
    matched = content.match(MAIN_JUDGE)
    if matched
      return matched[1].squish.delete("\r").delete(' ')
    else
      add_referee_error(crawler_history, referee, :parse_main_judge_empty, '取得 審判長法官 資訊為空')
      return nil
    end
  end

  def parse_judges_names(referee, content, crawler_history)
    content = content.tr('　', ' ')
    matched = content.match(JUDGE)
    if matched
      return content.scan(JUDGE).map { |i| i[0].squish.delete("\r").delete(' ') }
    else
      add_referee_error(crawler_history, referee, :parse_judge_error, '爬取法官格式錯誤, 撈取為空') if content =~ HAS_JUDGES
      add_referee_error(crawler_history, referee, :parse_judge_not_exist, '裁判書上沒有法官') unless content =~ HAS_JUDGES
      return []
    end
  end

  def parse_prosecutor_names(referee, content, crawler_history)
    matched = content.match(PROSECUTOR)
    if matched
      return content.scan(PROSECUTOR).map { |i| i[0] }
    else
      add_referee_error(crawler_history, referee, :parse_prosecutor_error, '爬取檢察官格式錯誤, 撈取為空') if content =~ HAS_PROSECUTOR
      add_referee_error(crawler_history, referee, :parse_prosecutor_not_exist, '裁判書上沒有檢察官') unless content =~ HAS_PROSECUTOR
      return []
    end
  end

  def parse_lawyer_names(referee, content, crawler_history)
    content = tuncate_role_data(content)
    matched = content.squish.match(LAWYER)
    if matched
      return content.squish.scan(LAWYER).map { |i| i[0] }
    else
      add_referee_error(crawler_history, referee, :parse_lawyer_error, '爬取律師格式錯誤, 撈取為空') if content =~ HAS_LAWYER
      add_referee_error(crawler_history, referee, :parse_lawyer_not_exist, '裁判書上沒有律師') unless content =~ HAS_LAWYER
      return []
    end
  end

  def parse_party_names(referee, content, crawler_history)
    parties = parse_roles_hash(referee, content, crawler_history).each_value.inject([]) { |a, e| a << e }
    parties = parties.flatten.reject { |e| e[/律師/] }
    return parties if parties.present?
    add_referee_error(crawler_history, referee, :parse_party_error, '爬取當事人格式錯誤, 撈取為空')
    []
  end

  def parse_roles_hash(referee, content, crawler_history)
    data = tuncate_role_data(content)
    role_number = 0
    new_line_count = data.scan("\r\n").count - 1
    role_array = data.scan(PARSE_ROLES_PATTERN)
    role_hash, sub_title_count = parse_role_array(role_array)
    role_hash.each_value { |v| role_number += v.count }
    expect_role_number = new_line_count - sub_title_count
    add_referee_error(crawler_history, referee, :parse_referee_role_error, '爬取裁判參與角色數量錯誤(內涵pattern 未收錄角色)') unless expect_role_number == role_number
    role_hash
  rescue
    add_referee_error(crawler_history, referee, :parse_referee_role_failed, "從內文解析角色失敗  內文: #{content}")
    {}
  end

  def parse_original_url(referee, original_data, crawler_history)
    Nokogiri::HTML(original_data).css('script')[4].text[/http:\/\/.+(?=;)/].delete('\"')
  rescue
    add_referee_error(crawler_history, referee, :parse_original_url_failed, '取得固定網址失敗')
    nil
  end

  def parse_stories_history_url(referee, original_data, crawler_history)
    path = Nokogiri::HTML(original_data).at_xpath('//a[text()="歷審裁判"]').attributes['href'].value
    HOST_URI + path
  rescue
    add_referee_error(crawler_history, referee, :parse_stories_history_url_failed, '取得歷審裁判 網址失敗')
    nil
  end

  def parse_reason(referee, original_data, crawler_history)
    Nokogiri::HTML(original_data).css('table')[2].css('table')[1].css('span')[2].text[/(?<=\u00a0)\p{Han}+/]
  rescue
    add_referee_error(crawler_history, referee, :parse_reason_failed, '取得案由失敗')
    nil
  end

  def parse_referee_type(content, crawler_history)
    content.split.first.match(/判決/).present? ? 'verdict' : 'rule'
  rescue
    Logs::AddCrawlerError.parse_referee_data_error(crawler_history, :parse_data_failed, "解析資訊錯誤 : 取得 裁判書類型 失敗, 內文: #{content}")
    false
  end

  def prase_related_stories(content)
    end_point = get_content_start_point(content)
    data = content[0..end_point]
    data.scan(/.{3}年度.+第.+號/)[1..-1]
  end

  def get_content_start_point(content)
    return content.index('上列') - 1 if content.index('上列')
    content.index(/[\p{han}\p{p}\d]{20}/)
  rescue
    Logs::AddCrawlerError.parse_referee_data_error(crawler_history, :parse_data_failed, "擷取內文起始點失敗, 內文: #{content}")
    100
  end

  private

  def tuncate_role_data(content)
    end_point = get_content_start_point(content)
    content.tr!('　', ' ')
    return content[0..end_point] unless start_word = content[0..end_point].scan(/.{3}年度.+第.+號/).last
    start_point = content[0..end_point].index(start_word)
    content[start_point..end_point]
  end

  def parse_role_array(role_array)
    sub_title_count = 0
    role_hash = {}
    role_array.each do |arr|
      sub_title_count += 1 if arr[1].present?
      title = arr[0..1].join.delete(' ')
      names = arr[2..-1].compact.map { |a| a.delete(' ') }.join.split("\r\n").uniq
      role_hash[title] ? role_hash[title] += names : role_hash[title] = names
    end
    [role_hash, sub_title_count]
  end

  def add_referee_error(crawler_history, referee, type, message)
    if referee.class == Verdict
      Logs::AddCrawlerError.add_verdict_error(crawler_history, referee, type, message)
    else
      Logs::AddCrawlerError.add_rule_error(crawler_history, referee, type, message)
    end
  end

end
