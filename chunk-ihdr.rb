class PngChunkIHDR < PngChunk
  def info
    info = super
    info[:IHDR] = Hash.new
    info[:IHDR][:width] = width
    info[:IHDR][:height] = height
    info[:IHDR][:bit_depth] = bit_depth
    info[:IHDR][:colour_type] = colour_type
    info[:IHDR][:compression_method] = compression_method
    info[:IHDR][:filter_method] = filter_method
    info[:IHDR][:interlace_method] = interlace_method 
    info
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
