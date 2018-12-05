class PngChunkIDAT < PngChunk
  def info
    info = super
    info[:IDAT] = Hash.new
    info[:IDAT][:compression_method] = compression_method
    info[:IDAT][:window_size] = window_size
    info[:IDAT][:compressed_size] = @data.length
    info[:IDAT][:uncompressed_size] = uncompressed_size
    info[:IDAT][:compression_ratio] = (@data.length.to_f / uncompressed_size.to_f).round(4)
    info[:IDAT][:zlib_header_checksum_ok] = zlib_header_checksum_ok? ? "Yes" : "No"
    # TODO: finish implementing zlib header info extraction
    info
  end

  # TODO: implement error checks

  def uncompressed_size
    begin
      return Zlib::Inflate.inflate(@data).length
    rescue Zlib::DataError
      puts "Error while inflating IDAT data."
      return -1
    end
  end

  def compression_method
    case @data[0].ord & 0x0F
      when 8
        :deflate
      when 15
        :reserved
      else
        :invalid
    end
  end

  def window_size
    return 2 ** (((@data[0].ord & 0xF0) >> 4) + 8)
  end

  def zlib_header_checksum_ok?
    ((@data[0].ord * 256 + (@data[1].ord & 0x0F)) % 31) == 0
  end
end
