class PngChunkIDAT < PngChunk
  def info
    info = super
    info[:IDAT] = Hash.new
    info[:IDAT][:compression_method] = compression_method
    info[:IDAT][:window_size] = window_size
    info[:IDAT][:compressed_size] = @data.length
    info[:IDAT][:uncompressed_size] = uncompressed_size
    info[:IDAT][:compression_ratio] = (@data.length.to_f / uncompressed_size.to_f).round(4)
    info[:IDAT][:compression_level] = compression_level
    info[:IDAT][:preset_dictionary_present] = has_preset_dictionary? ? "Yes" : "No"
    info[:IDAT][:zlib_header_checksum_ok] = zlib_header_checksum_ok? ? "Yes" : "No"
    info[:IDAT][:stored_zlib_data_checksum] = stored_zlib_data_checksum
    info[:IDAT][:actual_zlib_data_checksum] = actual_zlib_data_checksum
    info
  end

  def errors
    errors = super
    errors.push "Invalid compression method" if compression_method == :invalid
    errors.push "Window size is over 32768" if window_size > 32768
    errors.push "Has zlib preset dictionary which is disallowed by PNG specification" if has_preset_dictionary?
    errors.push "Zlib header checksum is incorrect" if !zlib_header_checksum_ok?
    errors.push "Zlib data checksum is incorrect" if !zlib_data_checksum_ok?
    errors
  end

  def uncompressed_data
    begin
      return Zlib::Inflate.inflate(@data)
    rescue Zlib::DataError
      puts "Error while inflating IDAT data."
      return ""  # TODO: better handling of corrupt uninflatable files
    end
  end

  def uncompressed_size
    uncompressed_data.length
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

  def compression_level
    case @data[1].ord & 0xC0 >> 6
      when 0
        :fastest
      when 1
        :fast
      when 2
        :default
      when 3
        :maximum_compression
    end
  end

  def zlib_header_checksum_ok?
    ((@data[0].ord * 256 + (@data[1].ord & 0x0F)) % 31) == 0
  end
  
  def zlib_data_checksum_ok?
    actual_zlib_data_checksum == stored_zlib_data_checksum
  end

  def actual_zlib_data_checksum
    Zlib::adler32 uncompressed_data
  end

  def stored_zlib_data_checksum
    @data[-4..-1].to_s.unpack("N")[0]
  end

  def has_preset_dictionary?
    @data[1].ord & 0x20 > 0
  end
end
