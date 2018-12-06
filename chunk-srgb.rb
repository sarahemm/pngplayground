class PngChunkSRGB < PngChunk
  def fields
    {
      :rendering_intent => {
        :offset => 0, :length => 1,
        :format => :enum,
        :enum => {
          0 => :perceptual,
          1 => :relative_colourimetric,
          2 => :saturation,
          3 => :relative_colourimetric
        }
      }
    }
  end

  def info
    info = super
    info[:sRGB] = Hash.new
    info[:sRGB][:rendering_intent] = rendering_intent
    info
  end

  def errors
    errors = super
    errors.push "Invalid rendering intent" if rendering_intent == :invalid
    errors
  end
end
