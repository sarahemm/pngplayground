class PngChunkPHYS < PngChunk
  def info
    info = super
    info[:pHYs] = Hash.new
    info[:pHYs][:pixels_per_unit_x] = ppu_x
    info[:pHYs][:pixels_per_unit_y] = ppu_y
    info[:pHYs][:unit] = unit
    info
  end

  def ppu_x
    @data[0..3].to_s.unpack("N")[0]
  end
  
  def ppu_y
    @data[4..7].to_s.unpack("N")[0]
  end

  def unit
    case @data[8].to_i
      when 0
        :unknown
      when 1
        :metre
      else
        :invalid
    end
  end
end
