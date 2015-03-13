require 'zlib'

module CgBItoPNG
  class Chunk
    attr_reader :type, :data

    def initialize(length, type, crc, data)
      raise ArgumentError.new("Length-field does not match length of data, specified '#{length}', got '#{data.length}'") unless data.length == length
      @type = type
      @data = data
      @crc = crc
    end

    def get_dimensions
      raise "No dimensions in this chunk (Expected 'IHDR', got '#{@type}')" unless @type == 'IHDR'
      ihdr = {}
      ihdr[:width] = @data[0...4].unpack(BIG_ENDIAN_LONG).first
      ihdr[:height] = @data[4...8].unpack(BIG_ENDIAN_LONG).first
      ihdr[:bit_depth] = @data[8].unpack(UINT_8).first
      ihdr[:color_type] = @data[9].unpack(UINT_8).first
      ihdr[:compression_method] = @data[10].unpack(UINT_8).first
      ihdr[:filter_method] = @data[11].unpack(UINT_8).first
      ihdr[:interlace_method] = @data[12].unpack(UINT_8).first

      raise "Not supported bit depth: '#{ihdr[:bit_depth]}'" unless ihdr[:bit_depth] == 8
      raise "Not supported bit depth: '#{ihdr[:color_type]}'" unless ihdr[:color_type] == 6
      raise "Not supported bit depth: '#{ihdr[:interlace_method]}'" unless ihdr[:interlace_method] == 0
      ihdr
    end

    # Need to change RGBA -> BGRA
    def self.replace_colors(blob, width, color_depth)
      fixed_blob = ""
      while blob.size > 0
        scanline_bytes = width * color_depth + 1
        scanline = blob.slice!(0, scanline_bytes)
        filterbyte = scanline.slice!(0, 1).b # filter byte at start of scanline
        fixed_blob << filterbyte
        while scanline.size > 0
          slice = scanline.slice!(0, 4).b

          # Red Gren Blue Alpha
          [2, 1, 0, 3].each do |color_idx|
            fixed_blob << slice[color_idx]
          end
        end
      end
      fixed_blob
    end

    def replace_data_with_blob(blob)
      @data = Zlib::Deflate.deflate(blob, Zlib::FINISH)
    end

    def make_crc
      crc = Zlib::crc32(@type)
      Zlib::crc32(@data, crc)
    end

    def to_blob
      blob = [@data.length].pack(BIG_ENDIAN_LONG)
      blob << @type
      blob << @data
      blob << [self.make_crc].pack(BIG_ENDIAN_LONG)
    end

    def to_s
      "Chunk type=#{@type}, #{@data.length}bytes"
    end

    def self.join_and_unoptimize_idat(chunks, image_width, color_depth)
      combined_data = ''
      chunks.each do |chunk|
        combined_data << chunk.data
      end
      inflator = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      blob = inflator.inflate(combined_data)

      inflator.close

      fixed_data = self.replace_colors(blob, image_width, color_depth)

      chunks.first.replace_data_with_blob(fixed_data)
      chunks.first
    end

    def self.get_chunks(data_blob)
      pngheader = PNG_HEADER
      blob_header = data_blob[0..7]
      hex_head = pngheader.unpack("H*").first
      hex_blob_head = blob_header.unpack("H*").first
      raise ArgumentError.new("Data is not a valid PNG file. Header missmatch (#{hex_head} != #{hex_blob_head})") unless pngheader == blob_header
      chunks = {}
      index = LEN_HEADER
      while index < data_blob.length
        chunk_length = data_blob[index...(index += LEN_LENGTH)].unpack(BIG_ENDIAN_LONG).first
        chunk_type = data_blob[index...(index += LEN_CHUNK_TYPE)]
        chunk_data = data_blob[index...(index += chunk_length)]
        chunk_crc = data_blob[index...(index += LEN_CRC)].unpack(BIG_ENDIAN_LONG).first
        chunks[chunk_type] ||= []
        chunks[chunk_type] << Chunk.new(chunk_length, chunk_type, chunk_crc, chunk_data)
      end
      chunks
    end
  end
end