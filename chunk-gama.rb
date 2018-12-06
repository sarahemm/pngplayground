class PngChunkGAMA < PngChunk
  def fields
    {
      :gamma => {
        :offset => 0, :length => 4,
        :format => :int4,
        :postproc => lambda { |input| input.to_f / 100000 }
      }
    }
  end
  
  def info
    info = super
    info[:gAMA] = Hash.new
    info[:gAMA][:gamma] = gamma
    info
  end
end
