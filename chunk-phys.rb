class PngChunkPHYS < PngChunk
  def info
    info_str = super
    info_str += "\npHYs Chunk Info\n"
    info_str += "Pixels per Unit X: #{ppu_x}\n"
    info_str += "Pixels per Unit Y: #{ppu_y}\n"
    info_str += "Unit: #{unit}\n"
    info_str
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
