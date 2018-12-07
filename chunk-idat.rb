class PngChunkIDAT < PngChunk
  def fields
    {
      :compression_method => {
        :offset => 0, :length => 1,
        :format => :enum,
        :preproc => lambda { |input| input & 0x0F },
        :write_preproc => lambda { |old, new| (old & 0xF0) | new },
        :enum =>  {
          8 => :deflate,
          15 => :reserved
        }
      },
      :window_size => {
        :offset => 0, :length => 1,
        :format => :int1,
        :postproc => lambda { |input| 2 ** (((input & 0xF0) >> 4) + 8) },
        :write_postproc => lambda { |old, new| (old & 0x0F) | ((Math::log2(new).to_i-8) << 4) }
      },
      :compression_level => {
        :offset => 1, :length => 1,
        :format => :enum,
        :preproc => lambda { |input| input & 0xC0 >> 6 },
        :enum => {
          0 => :fastest,
          1 => :fast,
          2 => :default,
          3 => :maximum_compression
        }
      },
      :has_preset_dictionary? => {
        :offset => 1, :length => 1,
        :format => :int1,
        :postproc => lambda { |input| input & 0x20 > 0 }
      },
      :stored_zlib_data_checksum => {
        :offset => -4, :length => 4,
        :format => :int4,
      },
    }
  end

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

  def zlib_header_checksum_ok?
    ((@data[0].ord * 256 + @data[1].ord) % 31) == 0
  end
  
  def fix_checksum
    # clear out the old (presumably bad) checksum
    data[1] = (data[1].ord & 0xE0).chr
    # calculate the new checksum
    checksum = 31 - (@data[0].ord * 256 + @data[1].ord) % 31
    # install the new checksum
    data[1] = ((data[1].ord & 0xE0) | checksum).chr
    # call our superclass's function to fix the chunk checksum
    super
  end

  def zlib_data_checksum_ok?
    actual_zlib_data_checksum == stored_zlib_data_checksum
  end

  def actual_zlib_data_checksum
    Zlib::adler32 uncompressed_data
  end
end
