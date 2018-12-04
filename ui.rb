require 'readline'
require 'zlib'

# TODO: filenames with spaces aren't supported yet and should be
class UI
  @cmd_list = {
    /help/ => :help,
    /show chunks/ => :show_chunks,
    /extract (\S+) (\S+) ?(\S*)/ => :extract_chunk
  }

  def self.Launch(pngfile)
    puts "\nType 'help' for list of supported commands."

    while input = Readline.readline("\n> ", true)
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
    puts "extract chunk_type file [whole-chunk] - Extract one chunk into a separate file."
  end

  def self.extract_chunk(pngfile, type, filename, extract_what)
    # TODO: make sure file doesn't exist first
    chunks = pngfile.chunk(type)
    # TODO: support selecting a chunk to extract if there's >1 of a type
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
end
