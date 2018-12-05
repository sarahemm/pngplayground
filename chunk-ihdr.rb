class PngChunkIHDR < PngChunk
  def info
    info_str = super
    info_str += "\nIHDR Chunk Info\n"
    info_str += "Width: #{width}\n"
    info_str += "Height: #{height}\n"
    info_str += "Bit Depth: #{bit_depth}\n"
    info_str += "Colour Type: #{colour_type}\n"
    info_str += "Compression Method: #{compression_method}\n"
    info_str += "Filter Method: #{filter_method}\n"
    info_str += "Interlace Method: #{interlace_method}\n"
    info_str
  end

  def width
    @data[0..3].to_s.unpack("N")[0]
  end
  
  def height
    @data[4..7].to_s.unpack("N")[0]
  end

  def bit_depth
    @data[8].to_i
  end

  def colour_type
    case @data[9].to_i
      when 0
        :greyscale
      when 2
        :truecolour
      when 3
        :indexed_colour
      when 4
        :greyscale_with_alpha
      when 6
        :truecolour_with_alpha
      else
        :invalid
    end
  end

  def compression_method
    case @data[10].to_i
      when 0
        :deflate
      else
        :invalid
    end
  end

  def filter_method
    case @data[11].to_i
      when 0
        :adaptive_filtering
      else
        :invalid
    end
  end

  def interlace_method
    case @data[12].to_i
      when 0
        :none
      1
        :adam7
    end
  end
end
