class PngChunkPHYS < PngChunk
  def fields
    {
      :ppu_x => {
        :offset => 0, :length => 4,
        :format => :int4
      },
      :ppu_y => {
        :offset => 4, :length => 4,
        :format => :int4
      },
      :unit => {
        :offset => 8, :length => 1,
        :format => :enum,
        :enum => {
          0 => :unknown,
          1 => :metre
        }
      }
    }
  end

  def info
    info = super
    info[:pHYs] = Hash.new
    info[:pHYs][:pixels_per_unit_x] = ppu_x
    info[:pHYs][:pixels_per_unit_y] = ppu_y
    info[:pHYs][:unit] = unit
    info
  end
end
