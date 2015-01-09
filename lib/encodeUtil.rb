
require 'nkf'

def sanitize_string (str)
  str.encode("UTF-8").gsub(/[[:cntrl:]]/,"")
end

def strict_convert_into_utf16(str)

  return "" unless str

  # ソースがUTF-16でも-w16Bに統一するため、インプット-W16としてエンコードする
  guessCode_to_nkfOption_hash = {
    NKF::JIS => "-J",
    NKF::EUC => "-E",
    NKF::SJIS => "--oc=CP932", # naruseさんのご指摘から
    NKF::BINARY => "BINARY",
    NKF::UNKNOWN => "UNKNOWN(ASCII)",
    NKF::UTF8 => "-w",
    NKF::UTF16 => "-W16"
  }

  guess_code = NKF.guess(str)
  input_option_nkf = guessCode_to_nkfOption_hash[guess_code]

  if input_option_nkf == guessCode_to_nkfOption_hash[NKF::UNKNOWN] &&
      input_option_nkf == guessCode_to_nkfOption_hash[NKF::BINARY] then
    raise "文字コードが判別できません"
  end

  p input_option_nkf
  return NKF.nkf("#{input_option_nkf} -w",str)
end

UNESCAPE_WORKER_ARRAY = []
def unescape(str)
str.gsub(/\\u([0-9a-f]{4})/) {
UNESCAPE_WORKER_ARRAY[0] = $1.hex
UNESCAPE_WORKER_ARRAY.pack("U")
}
end