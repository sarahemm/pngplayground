require 'readline'
require 'zlib'

# TODO: filenames with spaces aren't supported yet and should be
# TODO: support multiple chunks of one type
class UI
  @cmd_list = {
    /help/ => :help,
    /show chunks/ => :show_chunks,
    /show chunk (\S+)/ => :show_chunk,
    /extract (\S+) (\S+) ?(\S*)/ => :extract_chunk
  }

  def self.Launch(pngfile)
    puts "\nType 'help' for list of supported commands."

    while input = Readline.readline("\npngplayground> ", true)
      break if input == "exit"
      process_command pngfile, input
    end
  end

  def self.process_command(pngfile, input)
    @cmd_list.each do |re, cmd|
      if(matches = re.match(input)) then
        args = re.match(input).to_a
        # get rid of 0 (full matched string) as functions don't need it
        args.shift
        # call the required command, passing the regex matches as arguments
        self.send cmd, pngfile, *args
        return
      end
    end
    puts "Command not recognised."
  end

  def self.help(pngfile)
    puts "exit - Exit pngplayground."
    puts "show chunks - List all chunks and high-level stats."
    puts "show chunk chunk_type - Show detailed info about a chunk."
    puts "extract chunk_type file [whole-chunk] - Extract one chunk into a separate file."
  end

  def self.extract_chunk(pngfile, type, filename, extract_what)
    # TODO: make sure file doesn't exist first
    chunks = pngfile.chunk(type)
    if(chunks.length > 1) then
      puts "Extracting chunks where more than one instance exists is not yet supported."
      return
    elsif(chunks.length == 0) then
      puts "No #{type} chunks found."
      return
    end
    puts "Extracting chunk of type #{type} to file #{filename}."
    exfile = File.open(filename, "w")
    # TODO: support exporting the whole chunk including header/length/CRC
    exfile.write chunks[0].data
    exfile.close
  end

  def self.show_chunks(pngfile)
    pngfile.chunks.each do |chunk|
      puts "#{chunk.type} - #{chunk.data.length} bytes - #{chunk.crc_ok? ? 'CRC OK' : 'CRC FAIL'}"
    end
  end

  def self.show_chunk(pngfile, type)
    # TODO: should be extended with chunk-specific info in an extensible way
    chunks = pngfile.chunk(type)
    if(chunks.length == 0) then
      puts "No #{type} chunks found."
      return
    end
    chunk = chunks[0]
    flags = Array.new
    flags.push "Critical" if chunk.is_critical?
    flags.push chunk.is_public? ? "Public" : "Private"
    flags.push "Copy-safe" if chunk.is_copysafe?
    puts "Type: #{chunk.type}"
    puts "Size: #{chunk.data.length}"
    puts "Flags: #{flags.join(", ")}"
    puts "Stored CRC: #{sprintf "0x%08X", chunk.crc} (#{chunk.crc_ok? ? "OK" : "Bad"})"
    puts "Actual CRC: #{sprintf "0x%08X", chunk.actual_crc}"
  end
end
