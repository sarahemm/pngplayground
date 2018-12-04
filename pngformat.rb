class PngFile
  attr_accessor :header, :chunks

  def initialize(pngfile)
    @header = PngFileHeader.new(pngfile)
    puts "Reading header..."
    @chunks = Array.new
    print "Reading chunks: "
    while(@chunks.push PngChunk.new(pngfile))
      print "#{@chunks[chunks.length-1].type}, "
      break if @chunks[chunks.length-1].type == "IEND"
    end
    puts "done."
  end

  def chunk(type)
    @chunks.select {|chunk| chunk.type == type}
  end
end

class PngFileHeader
  attr_reader :high_bit_check, :sig, :dos_eof, :dos_line_end, :unix_line_end

  def initialize(pngfile)
    data_str = pngfile.read(8)
    throw IOError if data_str.length != 8
    data = data_str.split(//)
    @high_bit_check = data[0].ord
    @sig = data[1..3].join("")
    @dos_line_end = [data[4].ord, data[5].ord]
    @dos_eof = data[6].ord
    @unix_line_end = data[7].ord
  end

  def validate
    check(@high_bit_check, 0x89, "High-bit check byte")
    check(@sig, "PNG", "Signature")
    check(@dos_line_end, [0x0D, 0x0A], "DOS line ending")
    check(@dos_eof, 0x1A, "DOS EOF")
    check(@unix_line_end, 0x0A, "UNIX line ending")
  end
end

class PngChunk
  attr_reader :type, :data, :crc

  def initialize(pngfile)
    length = pngfile.read(4).unpack("N")[0]
    @type = pngfile.read(4)
    @data = pngfile.read(length)
    @crc = pngfile.read(4)
  end
end
