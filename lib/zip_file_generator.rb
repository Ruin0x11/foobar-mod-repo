require 'zip'

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_stream)
    @input_dir = input_dir
    @output_stream = output_stream
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w(. ..)

    write_entries entries, '', @output_stream
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, output_stream)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      next if File.symlink? disk_file_path

      puts "Deflating #{disk_file_path}"

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, output_stream, zipfile_path)
      else
        put_into_archive(disk_file_path, output_stream, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, output_stream, zipfile_path)
    subdir = Dir.entries(disk_file_path) - %w(. ..)
    write_entries subdir, zipfile_path, output_stream
  end

  def put_into_archive(disk_file_path, output_stream, zipfile_path)
    output_stream.put_next_entry(zipfile_path)
    output_stream.write(File.open(disk_file_path, 'rb').read)
  end
end
