require 'readline'
require 'zlib'

# TODO: filenames with spaces aren't supported yet and should be
# TODO: support multiple chunks of one type
class UI
  @cmd_list = {
    /help/ => :help,
    /show chunks/ => :show_chunks,
    /show chunk (\S+)/ => :show_chunk,
    /validate chunks/ => :validate_chunks,
    /validate chunk (\S+)/ => :validate_chunk,
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
    puts "validate chunks - Validate all chunks."
    puts "validate chunk chunk_type - Validate a chunk."
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
    chunks = pngfile.chunk(type)
    if(chunks.length == 0) then
      puts "No #{type} chunks found."
      return
    end
    chunk_info = chunks[0].info
    chunk_info.each do |category, fields|
      puts "\n#{category == :generic ? "Generic" : category} Chunk Info"
      fields.each do |field, value|
        field_name = field.to_s.gsub("_", " ").capitalize
        puts "#{field_name}: #{value}"
      end
    end
  end

  def self.validate_chunks(pngfile)
    pngfile.chunks.each do |chunk|
      chunk_errors = chunk.errors
      if(chunk_errors == []) then
        puts "#{chunk.type}: No errors"
      else
        chunk_errors.each do |error|
          puts "#{chunk.type}: #{error}"
        end
      end
    end
  end

  def self.validate_chunk(pngfile, type)
    chunks = pngfile.chunk(type)
    if(chunks.length == 0) then
      puts "No #{type} chunks found."
      return
    end
    chunk_errors = chunks[0].errors
    if(chunk_errors == []) then
      puts "#{type} chunk has no errors."
    else
      puts chunk_errors.join("\n")
    end
  end
end
