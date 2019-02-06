require 'zip'

def get_dirs_from_zip(zip_path)
    Zip::File.open(zip_path) do |in_zip|
    in_zip.select(&:directory?)
    end
end

dir_list = get_dirs_from_zip('j1.jar')
Zip::File.open('j2.jar') do |in_zip|
    dir_list.each do |dir|
     in_zip.remove(dir)
    end
end
