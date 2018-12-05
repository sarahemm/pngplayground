class PngChunkSRGB < PngChunk
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

  def rendering_intent
    case @data[0].to_i
      when 0
        :perceptual
      when 1
        :relative_colourimetric
      when 2
        :saturation
      when 3
        :relative_colourimetric
      else
        :invalid
    end
  end
end
