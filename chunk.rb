require 'zlib'

class PngChunk
  attr_reader :type, :data, :crc
  
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
    if(m[-1] == "=") then
      set_field m[0..-2].to_sym, args[0]
    else
      read_field m
    end
  end
  
  def set_field(field, new_value)
    field = fields[field]
    raise NameError, "No such field #{m}" if !fields.has_key? field
    # TODO: permit fields with postprocs to be set
    if(field[:postproc]) then
      puts "Fields with post-processing lambdas are not yet settable."
      return
    end
    # TODO: permit fields with other formats to be set
    case field[:format]
      when :int1
        @data[field[:offset]] = new_value.to_i.chr
      else
        puts "Fields with format #{field[:format]} are not yet settable."
    end
  end

  def read_field(field)
    field = fields[field]
    raise NameError, "No such field #{m}" if !field
    field_data = @data[field[:offset]..field[:offset] + (field[:length]-1)]
    case field[:format]
      when :int1
        out_data = field_data.ord.to_i
      when :int4
        out_data = field_data.to_s.unpack("N")[0]
      when :enum
        value = field_data.ord.to_i
        value = field[:preproc].call(value) if field[:preproc]
        if(field[:enum].has_key? value) then
          out_data = field[:enum][value]
        else
          out_data = :invalid
        end
      else
        throw NameError, "Invalid field format #{field[:format]}"
    end
    return 0 if !out_data
    out_data = field[:postproc].call(out_data) if field[:postproc]
    out_data
  end
end
