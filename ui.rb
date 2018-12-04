require 'readline'

class UI
  def self.Launch(pngfile)
    puts "\nType 'help' for list of supported commands."

    while input = Readline.readline("> ", true)
      break if input == "exit"
      process_command pngfile, input
    end
  end

  # TODO: filenames with spaces aren't supported yet and should be
  def self.process_command(pngfile, input)
    input_args = input.split(/\s+/)
    case input_args[0]
      when "help"
        puts "extract chunk_type file [whole-chunk] - Extract one chunk into a separate file."
      when "extract"
        type = input_args[1]
        filename = input_args[2]
        extract_what = input_args[3] or "data-only"
        extract_chunk pngfile, type, filename, extract_what
      when "show"
        case input_args[1]
          when "chunks"
            show_chunks pngfile
        end
    end
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
      puts "#{chunk.type} - #{chunk.data.length} bytes"
    end
  end
end
