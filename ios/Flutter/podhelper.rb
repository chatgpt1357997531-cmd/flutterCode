require 'fileutils'
require 'json'

def parse_KV_file(file, separator = '=')
  file_abs_path = File.expand_path(file)
  return {} unless File.exist? file_abs_path

  generated_key_values = {}
  File.foreach(file_abs_path) do |line|
    line = line.strip
    next if line.length == 0 || line[0] == "#"

    separator_index = line.index(separator)
    next if separator_index.nil?

    key = line[0...separator_index].strip
    value = line[(separator_index + 1)..-1].strip
    if value.length >= 2 && ((value[0] == '"' && value[-1] == '"') || (value[0] == "'" && value[-1] == "'"))
      value = value[1...-1]
    end
    generated_key_values[key] = value
  end
  generated_key_values
end

def flutter_root
  generated_xcode_build_settings = parse_KV_file(File.join(__dir__, '..', 'Flutter', 'Generated.xcconfig'))
  if generated_xcode_build_settings.empty?
    raise "#{File.join(__dir__, '..', 'Flutter', 'Generated.xcconfig')} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end
  generated_xcode_build_settings['FLUTTER_ROOT']
end

def flutter_ios_engine_podspec
  File.expand_path(File.join(__dir__, '..', 'Flutter', 'ephemeral', 'Flutter-Engine.podspec'))
end

def install_flutter_engine_pod
  # Keep in sync with flutter/tools/gn in the flutter repo.
  engine_dir = File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine')
  unless File.exist?(engine_dir)
    raise "#{engine_dir} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end
  unless File.exist?(flutter_ios_engine_podspec)
    raise "#{flutter_ios_engine_podspec} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end
  pod 'Flutter', :podspec => flutter_ios_engine_podspec
end

def install_flutter_plugin_pods(plugin_directory)
  flutter_plugin_pods_file = File.join(plugin_directory, '.flutter-plugins-dependencies')
  unless File.exist?(flutter_plugin_pods_file)
    raise "#{flutter_plugin_pods_file} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end
  plugin_pods = JSON.parse(File.read(flutter_plugin_pods_file))
  plugin_pods['plugins']['ios'].each do |plugin|
    pod plugin['name'], :path => plugin['path']
  end
end

def install_all_flutter_pods(flutter_application_path)
  install_flutter_engine_pod
  install_flutter_plugin_pods(flutter_application_path)
end
