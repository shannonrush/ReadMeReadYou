class ContentFixer

  def self.fix(file)
    file_string = file.read
    return file_string.gsub(/\r\n/,"\n\n")
  end

end
