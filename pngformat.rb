require 'zlib'

class PngFile
  attr_accessor :header, :chunks

  def initialize(pngfile)
    @header = PngFileHeader.new(pngfile)
    puts "Reading header..."
    @chunks = Array.new
    print "Reading chunks: "
    while(@chunks.push load_chunk(pngfile))
      this_chunk = @chunks[chunks.length-1]
      crc_bad_flag = ""
      crc_bad_flag = " (CRC bad)" if !this_chunk.crc_ok?
      print "#{this_chunk.type}#{crc_bad_flag}, "
      # TODO: support trailer data after IEND
      break if this_chunk.type == "IEND"
    end
    puts "done."
  end
  
  def load_chunk(pngfile)
    # peek at what the type is so we know what subclass to instantiate
    length = pngfile.read(4)
    type = pngfile.read(4)
    # put the file position back to the start of this block
    pngfile.seek(-8, IO::SEEK_CUR)
    begin
      chunk_class = Object.const_get("PngChunk#{type.upcase}")
      return chunk_class.new(pngfile)
    rescue NameError
      return PngChunk.new(pngfile)
    end
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

