module BeefsHelper
  require 'nokogiri'
  require 'open-uri'
  def beef_createtime(created_at)
    time_gap = Time.now - created_at
    if time_gap < 1.day.second then
      diff = time_gap / 1.hour.second
      time_result = "#{diff.floor} #{I18n.t('resource.hours_ago_submit')},"
    elsif time_gap >= 1.day.second && time_gap < 1.month.second then
      diff = time_gap / 1.day.second
      time_result = "#{diff.floor} #{I18n.t('resource.days_ago_submit')},"
    elsif time_gap >= 1.month.second && time_gap < 1.year.second then
      diff = time_gap / 1.month.second
      time_result = "#{diff.floor} #{I18n.t('resource.months_ago_submit')},"
    elsif time_gap >= 1.year.second then
      diff = time_gap / 1.year.second
      time_result = "#{diff.floor} #{I18n.t('resource.years_ago_submit')}"
    end
    return time_result
  end

  def image_not_exists?(beef)
    html_doc = Nokogiri::HTML(beef.description)
    image_data = html_doc.xpath("//img")
    return image_data.blank?
  end

  def html_content_parsed(beef)
    html_doc = Nokogiri::HTML(beef.description)
    if image_not_exists?(beef)
      text_result = truncate(html_doc.xpath("//p").text, length: 300)
    else
      text_result = truncate(html_doc.xpath("//p").text, length: 80)
    end
    return text_result
  end

  def html_image_parsed(beef,seq,width,height)
    html_doc = Nokogiri::HTML(beef.description)
    image_data = html_doc.xpath("//img")
    if image_data.blank? || image_data[seq].blank? then
      return nil
    else
      image_src = image_data[seq]["src"]
      image_tag(image_src, width: width, height: height)
    end
  end
end
