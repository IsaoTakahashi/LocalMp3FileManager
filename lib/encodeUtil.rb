
require 'nkf'

def sanitize_string (str)
  str.encode("UTF-8").gsub(/[[:cntrl:]]/,"")
end