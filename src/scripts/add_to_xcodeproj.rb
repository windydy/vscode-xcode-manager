#!/usr/bin/env ruby
# VS Code Extension - add_to_xcodeproj.rb
# Add files or directories to Xcode project

require 'xcodeproj'
require 'pathname'
require 'set'

if ARGV.size < 1
  puts "Usage: ruby add_to_xcodeproj.rb <file_or_dir> [more files...]"
  exit 1
end

# ===============================
# Find xcodeproj
# ===============================
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

# Get the first argument to find project
first_path = Pathname.new(ARGV.first).expand_path
xcodeproj_path = find_xcodeproj(first_path.directory? ? first_path : first_path.dirname)

project = Xcodeproj::Project.open(xcodeproj_path)
project_root = Pathname.new(xcodeproj_path).parent

puts "📦 Using Xcode project: #{File.basename(xcodeproj_path)}"

# ===============================
# Collect all files to add
# ===============================
input_files = Set.new
input_dirs = Set.new

ARGV.each do |arg|
  path = Pathname.new(arg).expand_path
  next unless path.exist?

  if path.directory?
    # Track the directory itself
    input_dirs << path
    
    path.find do |p|
      input_files << p if p.file? && !['.DS_Store'].include?(p.basename.to_s)
    end
  else
    input_files << path
  end
end

# If no files but have directories, we'll create empty groups
if input_files.empty? && input_dirs.empty?
  abort "❌ No valid files or directories found"
end

# ===============================
# Helper: Find or create group
# ===============================
def find_or_create_group(parent, name, insert_at_top = false)
  existing_group = parent.groups.find { |g| g.display_name == name }
  return existing_group if existing_group
  
  # Create new group
  new_group = parent.new_group(name, name)
  
  # Move to first position if requested
  if insert_at_top && parent.children.size > 1
    parent.children.delete(new_group)
    parent.children.unshift(new_group)
  end
  
  new_group
end

# ===============================
# Process empty directories first
# ===============================
created_groups = Set.new

input_dirs.each do |dir_path|
  relative_path = dir_path.relative_path_from(project_root)
  parts = relative_path.each_filename.to_a

  current_group = project.main_group

  # Create all directory groups in the path
  parts.each_with_index do |dir, index|
    parent_group = current_group
    # Only insert at top for the final (leaf) directory
    is_leaf = (index == parts.length - 1)
    current_group = find_or_create_group(parent_group, dir, is_leaf)
    
    # Track that we created this group (only if it's new)
    created_groups << current_group if is_leaf
  end

  puts "📁 Created group: #{relative_path}"
end

# ===============================
# Process each file
# ===============================
added_count = 0

input_files.each do |file_path|
  relative_path = file_path.relative_path_from(project_root)
  parts = relative_path.each_filename.to_a

  current_group = project.main_group

  # Create directory groups
  parts[0..-2].each do |dir|
    current_group = find_or_create_group(current_group, dir)
  end

  filename = parts.last

  # Skip if already exists
  if current_group.files.any? { |f| f.display_name == filename }
    puts "⚠️  Skipped #{filename} (already exists in project)"
    next
  end

  file_ref = current_group.new_file(filename)

  # Add to build phase (only for native targets)
  project.targets.each do |target|
    # Skip non-native targets (e.g., PBXAggregateTarget)
    next unless target.is_a?(Xcodeproj::Project::Object::PBXNativeTarget)
    
    case file_path.extname
    when '.m', '.mm', '.swift'
      target.source_build_phase.add_file_reference(file_ref)
    when '.storyboard', '.xib', '.xcassets', '.png', '.jpg', '.jpeg'
      target.resources_build_phase.add_file_reference(file_ref)
    end
  end

  puts "➕ Added #{relative_path}"
  added_count += 1
end

if added_count > 0 || created_groups.any?
  project.save
  
  if added_count > 0 && created_groups.any?
    puts "✅ Successfully added #{added_count} file(s) and #{created_groups.size} group(s) to Xcode project"
  elsif added_count > 0
    puts "✅ Successfully added #{added_count} file(s) to Xcode project"
  else
    puts "✅ Successfully added #{created_groups.size} group(s) to Xcode project"
  end
else
  puts "ℹ️  No new files or groups were added"
end
