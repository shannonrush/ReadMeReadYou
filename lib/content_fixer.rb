class ContentFixer

  COMMON = ["the","be","to","of","and","a","in","that","have","i","it","for","not","on","with","he","as","you","do","at","this","but","his","by","from","they","we","say","her","she","or","an","will","my","one","all","would","there","their","what","so","up","out","if","about","who","get","which","go","me"]

  def self.fix(file)
    file_string = file.read
    file_string.gsub!(/\r\n/,"\n\n")
    file_string.gsub!(/\xE2\x80\x9D/,'&quot;')
    file_string.gsub!(/\xE2\x80\x9C/,'&quot;')
    file_string.gsub!(/\xE2\x80\x98/,'&#39;')
    file_string.gsub!(/\xE2\x80\x99/,'&#39;')
    return file_string
  end

  def self.quotes_to_symbols(content)
    content = content.clone
    content.gsub!(/&quot;/,'"')
    content.gsub!(/&#39;/,"'")
    return content
  end

  def self.quotes_to_code(content)
    content = content.clone
    content.gsub!(/"/,'&quot;')
    content.gsub!(/'/,"&#39;")
    return content
  end

  def self.process_for_analysis(content)
    content = content.clone
    abbreviations = ["Mr.","Mrs.","Ms."]
    content.gsub!("_","")
    abbreviations.each {|a| content.gsub!(a,a.chop)}
    content = ContentFixer.quotes_to_symbols(content)
    return content
  end

  def self.remove_quotes(content)
    content = content.clone
    content.gsub!(/["']/,"")
    content.gsub!(/&quot;/,"")
    content.gsub!(/&#39;/,"")
    return content
  end

  def self.remove_punctuation(content) 
    content = content.clone
    content.gsub!(/[0-9\?\.!,*\(\)\[\]:\;\-]/,"")
    content.gsub!(/\//," ")
    return content
  end

  def self.remove_common(content)
    words = content.clone.split
    words.delete_if {|w| COMMON.include?(w.downcase)}
    return words.join(" ")
  end
end
