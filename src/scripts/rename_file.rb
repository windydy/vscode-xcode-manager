#!/usr/bin/env ruby
# VS Code Extension - rename_file.rb
# Rename a file and update references in Xcode project

require 'xcodeproj'
require 'pathname'
require 'fileutils'

if ARGV.size < 2
  puts "Usage: ruby rename_file.rb <old_path> <new_name>"
  exit 1
end

old_path = ARGV[0]
new_name = ARGV[1]

unless File.exist?(old_path)
  abort "❌ File does not exist: #{old_path}"
end

if File.directory?(old_path)
  abort "❌ Path is a directory, not a file. Use rename_folder.rb instead."
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

def find_file_references(project, file_path)
  references = []
  project.files.each do |file_ref|
    if file_ref.real_path&.to_s == file_path
      references << file_ref
    end
  end
  references
end

# ============================================================
# Main Logic
# ============================================================

old_pathname = Pathname.new(old_path).expand_path
old_dir = old_pathname.dirname
new_path = File.join(old_dir, new_name)

# Check if new file already exists
if File.exist?(new_path) && old_path != new_path
  abort "❌ A file with the name '#{new_name}' already exists in this directory"
end

# Find and open Xcode project
xcodeproj_path = find_xcodeproj(old_dir)
project = Xcodeproj::Project.open(xcodeproj_path)

puts "📦 Using Xcode project: #{File.basename(xcodeproj_path)}"
puts "📄 Renaming: #{File.basename(old_path)} → #{new_name}"

# Find file references in Xcode project
file_refs = find_file_references(project, old_path)

if file_refs.empty?
  puts "⚠️  File not found in Xcode project, will only rename the physical file"
else
  puts "🔍 Found #{file_refs.size} reference(s) in Xcode project"
  
  # Update each file reference
  file_refs.each do |file_ref|
    # Update the file reference path
    file_ref.path = new_name
    puts "✅ Updated reference in Xcode project"
  end
  
  # Save the project
  project.save
  puts "💾 Saved Xcode project"
end

# Rename the physical file
begin
  FileUtils.mv(old_path, new_path)
  puts "✅ Renamed file on disk: #{new_name}"
rescue => e
  abort "❌ Failed to rename file: #{e.message}"
end

puts "🎉 File renamed successfully!"
