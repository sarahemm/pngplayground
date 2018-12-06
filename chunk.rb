require 'zlib'

class PngChunk
  attr_reader :type, :data, :crc
  
  @@fields = {}

  def initialize(pngfile)
    length = pngfile.read(4).unpack("N")[0]
    @type = pngfile.read(4)
    @data = pngfile.read(length)
    @crc = pngfile.read(4).to_s.unpack("N")[0]
  end

  def info
    flags = Array.new
    flags.push "Critical" if is_critical?
    flags.push is_public? ? "Public" : "Private"
    flags.push "Copy-safe" if is_copysafe?
    info = Hash.new
    info[:generic] = Hash.new
    info[:generic][:type] = @type
    info[:generic][:size] = @data.length
    # TODO: make these two nicer
    info[:generic][:flags] = flags.join(", ")
    info[:generic][:stored_crc] = @crc
    info[:generic][:actual_crc] = actual_crc
    info[:generic][:crc_ok] = crc_ok? ? "Yes" : "No"
    info
  end

  def errors
    errors = Array.new
    errors.push "Chunk has incorrect CRC" if !crc_ok?
    errors
  end

  def actual_crc
    Zlib::crc32 @type + @data
  end

  def crc_ok?
    actual_crc == @crc
  end

  def is_critical?
    @type[0].is_upper?
  end

  def is_public?
    @type[1].is_upper?
  end

  def is_copysafe?
    @type[3].is_upper?
  end
  
  def method_missing(m, *args, &block)
    field = @@fields[m]
    throw NameError, "No such field #{m}" if !field
    field_data = @data[field[:offset]..field[:offset] + (field[:length]-1)]
    case field[:format]
      when :int1
        return field_data.ord.to_i
      when :int4
        return field_data.to_s.unpack("N")[0]
      when :enum
        if(field[:enum].has_key? field_data.ord.to_i) then
          return field[:enum][field_data.ord.to_i]
        else
          return :invalid
        end
      else
        throw NameError, "Invalid field format #{field[:format]}"
    end
    return 0
  end
end
