require 'cgbi_to_png/version'
require 'cgbi_to_png/png_file.rb'

module CgBItoPNG
  PNG_HEADER = "\x89PNG\r\n\x1a\n".force_encoding('ASCII-8BIT').freeze
  LEN_HEADER = 8
  LEN_LENGTH = 4
  LEN_CHUNK_TYPE = 4
  LEN_CRC = 4
  BIG_ENDIAN_LONG = 'L>'
  UINT_8 = 'C'
  COMPRESS_WINDOW_BITS = 8

  def self.from_file(file_path)
    raise ArgumentError.new("File #{file_path} does not exist") unless File.exists?(file_path)
    raise ArgumentError.new("File #{file_path} is not readable for current user") unless File.readable?(file_path)
    png_contents = File.open(file_path, 'rb') { |file| file.read }
    PNGfile.new(png_contents)
  end
end
