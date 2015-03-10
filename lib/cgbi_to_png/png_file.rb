require 'cgbi_to_png/chunk'

module CgBItoPNG
  class PNGfile
    def initialize(data_blob)
      @blob = data_blob
      @chunks = Chunk.get_chunks(data_blob)
      @ihdr = @chunks['IHDR'].first.get_dimensions
      @width = @ihdr[:width]
      @height = @ihdr[:height]
    end

    def to_s
      str = "Pngfile #{@chunks.length} chunks."
      str << " (Contains optimized chunk)" if self.optimized?
      @chunks.each do |_k, v|
        v.each do |c|
          str << "\n" << c.to_s
        end
      end
      str
    end

    def to_blob
      blob = PNG_HEADER
      @chunks.each do |_k, v|
        v.each do |chunk|
          next if chunk.type == 'CgBI'
          blob << chunk.to_blob
        end
      end
      blob
    end

    def to_file(filename)
      File.open(filename, 'wb+') do |f|
        f.write(self.to_blob)
      end
    end

    def optimized?
      @chunks['CgBI']
    end

    def unoptimize
      bytes_per_pixel = 4
      @chunks['IDAT'] =
          [ Chunk::join_and_unoptimize_idat(@chunks['IDAT'], @width, bytes_per_pixel) ]
      @chunks.delete('CgBI')
    end
  end
end