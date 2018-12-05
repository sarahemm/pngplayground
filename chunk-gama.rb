class PngChunkGAMA < PngChunk
  def info
    info = super
    info[:gAMA] = Hash.new
    info[:gAMA][:gamma] = gamma
    info
  end

  def gamma
    @data[0..3].to_s.unpack("N")[0].to_f / 100000
  end
end
