require 'zlib'

class PngChunk
  attr_reader :type, :data
  attr_accessor :crc
  
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

  def to_s
    [@data.length, @type, @data, @crc].pack("NA4A#{@data.length}N")
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
  
  def set_field(field_name, new_value)
    field = fields[field_name]
    if(!field) then
      puts "No such field #{field_name}.\nAvailable fields: #{fields.keys.join(", ")}"
      return
    end
    # TODO: permit fields with other formats to be set
    case field[:format]
      when :int1
        new_int = new_value.to_i
        p new_int
        new_int = field[:write_postproc].call(@data[field[:offset]].ord.to_i, new_int) if field[:write_postproc]
        p new_int
        @data[field[:offset]] = new_int.chr
      when :int4
        # TODO: permit fields with postprocs to be set
        if(field[:postproc]) then
          puts "Int4 fields with post-processing lambdas are not yet settable."
          return
        end
        @data[field[:offset]..field[:offset] + (field[:length]-1)] = [new_value.to_i].pack("N")
      when :enum
        new_int = field[:enum].key(new_value.to_sym)
        if(!new_int) then
          puts "No such value #{new_value} for field.\nAvailable values: #{field[:enum].values.join(", ")}"
          return
        end
        new_int = field[:write_preproc].call(@data[field[:offset]].ord.to_i, new_int) if field[:write_preproc]
        @data[field[:offset]] = new_int.chr
      else
        puts "Fields with format #{field[:format]} are not yet settable."
    end
  end

  def read_field(field)
    field = fields[field]
    raise NameError, "No such field #{field}" if !field
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

  def fix_checksum
    p @crc
    p actual_crc
    @crc = actual_crc
  end
end
