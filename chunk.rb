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
    info_str  = "Generic Chunk Info\n"
    info_str += "Type: #{@type}\n"
    info_str += "Size: #{@data.length}\n"
    info_str += "Flags: #{flags.join(", ")}\n"
    info_str += "Stored CRC: #{sprintf "0x%08X", @crc} (#{crc_ok? ? "OK" : "Bad"})\n"
    info_str += "Actual CRC: #{sprintf "0x%08X", actual_crc}\n"
    info_str
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
end

