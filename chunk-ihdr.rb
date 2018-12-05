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

  def errors
    errors = super
    errors.push "Invalid bit depth" if :bit_depth == :invalid
    errors.push "Invalid colour type" if :colour_type == :invalid
    errors.push "Invalid compression method" if :compression_method == :invalid
    errors.push "Invalid filter method" if :filter_method == :invalid
    errors.push "Invalid interlace method" if :interlace_method == :invalid
    case colour_type
      when :truecolour
        errors.push "Truecolour type does not permit bit depth #{bit_depth}" if ![8, 16].include? bit_depth
      when :indexed_colour
        errors.push "Indexed colour type does not permit bit depth #{bit_depth}" if ![1, 2, 4, 8].include? bit_depth
      when :greyscale_with_alpha
        errors.push "Greyscale with alpha colour type does not permit bit depth #{bit_depth}" if ![8, 16].include? bit_depth
      when :truecolour_with_alpha
        errors.push "Truecolour with alpha colour type does not permit bit depth #{bit_depth}" if ![8, 16].include? bit_depth
    end
    errors
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
