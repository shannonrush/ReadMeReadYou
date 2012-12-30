class ContentFixer

  def self.fix(file)
    file_string = file.read
    file_string.gsub!(/\r\n/,"\n\n")
    file_string.gsub!(/\xE2\x80\x9D/,'&quot;')
    file_string.gsub!(/\xE2\x80\x9C/,'&quot;')
    file_string.gsub!(/\xE2\x80\x98/,'&#39;')
    file_string.gsub!(/\xE2\x80\x99/,'&#39;')
    return file_string
  end

  def self.process_for_analysis(content)
    abbreviations = ["Mr.","Mrs.","Ms."]
    content.gsub!("_","")
    content.gsub!(/["']/, "")
    abbreviations.each {|a| content.gsub!(a,a.chop)}
    return content
  end

  def self.scrub(content)
    scrubbed = content.clone
    scrubbed.gsub!(/&quot;/,"")
    scrubbed.gsub!(/&#39;/,"")
    scrubbed.gsub!(/["'0-9\?\.!,*\(\)\[\]:\;\-]/,"")
    scrubbed.gsub!(/\//," ")
    return scrubbed
  end

end
