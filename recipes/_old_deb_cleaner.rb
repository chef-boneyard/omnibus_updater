old_debs =
  if ::File.exist?(node[:omnibus_updater][:cache_dir])
    Dir.glob(File.join(node[:omnibus_updater][:cache_dir], 'chef*.deb')).delete_if do |file|
      file.include?(node[:omnibus_updater][:version])
    end
  else
    []
  end

old_debs.each do |filename|
  file filename do
    action :delete
  end
end
