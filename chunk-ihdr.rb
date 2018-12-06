class PngChunkIHDR < PngChunk
  @@fields = {
    :width => {
      :offset => 0, :length => 4,
      :format => :int4
    },
    :height => {
      :offset => 4, :length => 4,
      :format => :int4
    },
    :bit_depth => {
      :offset => 8, :length => 1,
      :format => :int1
    },
    :colour_type => {
      :offset => 9, :length => 1,
      :format => :enum,
      :enum => {
        0 => :greyscale,
        2 => :truecolour,
        3 => :indexed_colour,
        4 => :greyscale_with_alpha,
        6 => :truecolour_with_alpha
      }
    },
    :compression_method => {
      :offset => 10, :length => 1,
      :format => :enum,
      :enum => {
        0 => :deflate
      }
    },
    :filter_method => {
      :offset => 11, :length => 1,
      :format => :enum,
      :enum => {
        0 => :adaptive
      }
    },
    :interlace_method => {
      :offset => 12, :length => 1,
      :format => :enum,
      :enum => {
        0 => :none,
        1 => :adam7
      }
    }
  }

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
end
