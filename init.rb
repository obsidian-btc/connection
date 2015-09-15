lib_path = File.expand_path "../lib", __FILE__

unless $LOAD_PATH.include? lib_path
  $LOAD_PATH << lib_path
end
