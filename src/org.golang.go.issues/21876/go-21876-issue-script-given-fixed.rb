require 'zip'

def get_dirs_from_zip(zip_path)
  Zip::File.open(zip_path) do |in_zip|
    in_zip.select(&:directory?)
  end
end

dir_list = get_dirs_from_zip(ARGV[0])
Zip::File.open(ARGV[1]) do |in_zip|
  dir_list.each do |dir|
    in_zip.remove(dir)
  end

  in_zip.entries.each do |e|
    puts "patch "+ e.name + ": e.gp_flags: "
    puts " %08b" % e.gp_flags
    e.gp_flags &= ~0x8
    puts "to\n %08b" % e.gp_flags
  end
end
