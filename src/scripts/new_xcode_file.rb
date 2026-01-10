#!/usr/bin/env ruby
# VS Code Extension - new_xcode_file.rb
# Generate Objective-C files from templates and add to Xcode project

require 'fileutils'
require 'xcodeproj'
require 'pathname'

# ============================================================
# Parse command-line arguments
# ============================================================

if ARGV.size < 4
  puts "Usage: ruby new_xcode_file.rb <class_name> <base_class> <output_dir> <template_root>"
  exit 1
end

class_name = ARGV[0]
base_class = ARGV[1]
output_dir = ARGV[2]
template_root = ARGV[3]

# ============================================================
# Helpers
# ============================================================

def valid_class_name?(name)
  name =~ /^[A-Z][A-Za-z0-9_]*$/
end

def find_xcodeproj(start_dir)
  current = Pathname.new(start_dir).expand_path
  
  # Search up to 5 levels
  5.times do
    xcodeproj_files = Dir.glob("#{current}/**/*.xcodeproj")
    return xcodeproj_files.first if xcodeproj_files.any?
    
    break if current.root?
    current = current.parent
  end
  
  abort "❌ No .xcodeproj found."
end

# ============================================================
# Validation
# ============================================================

abort "❌ Invalid class name: #{class_name}" unless valid_class_name?(class_name)

valid_base_classes = ["UIViewController", "UIView", "UITableViewCell", "NSObject"]
abort "❌ Invalid base class: #{base_class}" unless valid_base_classes.include?(base_class)

# ============================================================
# Generate Files
# ============================================================

template_dir = File.join(template_root, 'objc', 'cocoa_touch', base_class)
abort "❌ Template not found: #{template_dir}" unless Dir.exist?(template_dir)

FileUtils.mkdir_p(output_dir)

generated_files = []

Dir.glob("#{template_dir}/*").each do |tpl|
  content = File.read(tpl).gsub("___FILEBASENAME___", class_name)
  filename = File.basename(tpl).gsub("___FILEBASENAME___", class_name)
  path = File.join(output_dir, filename)

  if File.exist?(path)
    puts "⚠️  Skipped #{filename} (already exists)"
    next
  end

  File.write(path, content)
  generated_files << path
  puts "✅ Created #{filename}"
end

abort "❌ No files generated" if generated_files.empty?

# ============================================================
# Add to xcodeproj
# ============================================================

xcodeproj_path = find_xcodeproj(output_dir)
puts "📦 Adding to Xcode project: #{File.basename(xcodeproj_path)}"

project = Xcodeproj::Project.open(xcodeproj_path)
project_root = Pathname.new(xcodeproj_path).parent

def find_or_create_group(parent, name)
  parent.groups.find { |g| g.display_name == name } ||
    parent.new_group(name, name)
end

generated_files.each do |file_path|
  file_pathname = Pathname.new(file_path).expand_path
  relative_path = file_pathname.relative_path_from(project_root)
  parts = relative_path.each_filename.to_a

  current_group = project.main_group

  # Create directory groups
  parts[0..-2].each do |dir|
    current_group = find_or_create_group(current_group, dir)
  end

  filename = parts.last

  # Skip if already exists
  next if current_group.files.any? { |f| f.display_name == filename }

  file_ref = current_group.new_file(filename)

  # Add to build phase
  project.targets.each do |target|
    case file_pathname.extname
    when '.m', '.mm', '.swift'
      target.source_build_phase.add_file_reference(file_ref)
    when '.storyboard', '.xib', '.xcassets', '.png', '.jpg'
      target.resources_build_phase.add_file_reference(file_ref)
    end
  end

  puts "➕ Added #{filename} to Xcode"
end

project.save
puts "🎉 Done! Files added to Xcode project successfully."
