#!/usr/bin/env ruby
# VS Code Extension - rename_folder.rb
# Rename a folder and update all file/folder references in Xcode project

require 'xcodeproj'
require 'pathname'
require 'fileutils'

if ARGV.size < 2
  puts "Usage: ruby rename_folder.rb <old_path> <new_name>"
  exit 1
end

old_path = ARGV[0]
new_name = ARGV[1]

unless File.exist?(old_path)
  abort "❌ Folder does not exist: #{old_path}"
end

unless File.directory?(old_path)
  abort "❌ Path is a file, not a folder. Use rename_file.rb instead."
end

# ============================================================
# Helpers
# ============================================================

def find_xcodeproj(start_dir)
  current = Pathname.new(start_dir).expand_path
  
  # First, search upward from the start directory
  temp = current
  while !temp.root?
    xcodeproj_files = Dir.glob("#{temp}/*.xcodeproj")
    return xcodeproj_files.first if xcodeproj_files.any?
    temp = temp.parent
  end
  
  # If not found going up, search recursively downward from the original directory
  xcodeproj_files = Dir.glob("#{current}/**/*.xcodeproj")
  return xcodeproj_files.first if xcodeproj_files.any?
  
  abort "❌ No .xcodeproj found. Please ensure you're working in an Xcode project directory."
end

def find_group_by_path(parent, path_parts)
  return parent if path_parts.empty?
  
  next_part = path_parts.first
  child_group = parent.groups.find { |g| g.display_name == next_part || g.path == next_part }
  
  return nil unless child_group
  find_group_by_path(child_group, path_parts[1..-1])
end

def collect_all_file_paths(directory)
  files = []
  Dir.glob("#{directory}/**/*").each do |path|
    files << path if File.file?(path)
  end
  files
end

# ============================================================
# Main Logic
# ============================================================

old_pathname = Pathname.new(old_path).expand_path
old_dir = old_pathname.dirname
new_path = File.join(old_dir, new_name)

# Check if new folder already exists
if File.exist?(new_path) && old_path != new_path
  abort "❌ A folder with the name '#{new_name}' already exists in this directory"
end

# Find and open Xcode project
xcodeproj_path = find_xcodeproj(old_dir)
project = Xcodeproj::Project.open(xcodeproj_path)
project_root = Pathname.new(xcodeproj_path).parent

puts "📦 Using Xcode project: #{File.basename(xcodeproj_path)}"
puts "📁 Renaming folder: #{File.basename(old_path)} → #{new_name}"

# Collect all files in the old folder before renaming
old_file_paths = collect_all_file_paths(old_path)
puts "🔍 Found #{old_file_paths.size} file(s) in folder"

# Create a mapping of old paths to new paths
path_mapping = {}
old_file_paths.each do |old_file_path|
  relative_to_old_folder = Pathname.new(old_file_path).relative_path_from(old_pathname)
  new_file_path = File.join(new_path, relative_to_old_folder)
  path_mapping[old_file_path] = new_file_path
end

# Find the group in Xcode project
relative_path = old_pathname.relative_path_from(project_root)
path_parts = relative_path.each_filename.to_a

group = find_group_by_path(project.main_group, path_parts)

updated_refs = 0

if group.nil?
  puts "⚠️  Folder group not found in Xcode project"
else
  # Update the group's path/name
  group.path = new_name
  group.name = new_name
  puts "✅ Updated folder group in Xcode project"
  updated_refs += 1
end

# Update all file references
project.files.each do |file_ref|
  real_path = file_ref.real_path&.to_s
  next unless real_path
  
  if path_mapping.key?(real_path)
    # This file is inside the renamed folder
    new_file_path = path_mapping[real_path]
    
    # Calculate the new relative path from the group
    new_file_pathname = Pathname.new(new_file_path)
    new_folder_pathname = Pathname.new(new_path)
    
    # Update the file reference path relative to its parent group
    relative_to_new_folder = new_file_pathname.relative_path_from(new_folder_pathname)
    
    # Find the deepest parent that is a group
    parent = file_ref.parent
    while parent && !parent.is_a?(Xcodeproj::Project::Object::PBXGroup)
      parent = parent.parent
    end
    
    if parent && parent.real_path
      parent_path = Pathname.new(parent.real_path.to_s)
      relative_to_parent = new_file_pathname.relative_path_from(parent_path)
      file_ref.path = relative_to_parent.to_s
    else
      # Fallback: use relative path from new folder
      file_ref.path = relative_to_new_folder.to_s
    end
    
    updated_refs += 1
  end
end

puts "✅ Updated #{updated_refs} reference(s) in Xcode project"

# Save the project
project.save
puts "💾 Saved Xcode project"

# Rename the physical folder
begin
  FileUtils.mv(old_path, new_path)
  puts "✅ Renamed folder on disk: #{new_name}"
rescue => e
  abort "❌ Failed to rename folder: #{e.message}"
end

puts "🎉 Folder renamed successfully!"
puts "📝 All file and subfolder paths have been updated"
