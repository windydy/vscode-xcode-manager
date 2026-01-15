#!/usr/bin/env ruby
# VS Code Extension - fix_references.rb
# Fix broken references in Xcode project after moving files/folders

require 'xcodeproj'
require 'pathname'
require 'digest'

if ARGV.size < 1
  puts "Usage: ruby fix_references.rb <project_root_or_file_path>"
  exit 1
end

target_path = ARGV[0]

unless File.exist?(target_path)
  abort "❌ Path does not exist: #{target_path}"
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

def find_or_create_group(project, target_dir, project_root)
  relative_path = Pathname.new(target_dir).relative_path_from(project_root)
  path_parts = relative_path.each_filename.to_a
  
  current_group = project.main_group
  path_parts.each do |part|
    existing_group = current_group.groups.find { |g| g.display_name == part || g.path == part }
    if existing_group
      current_group = existing_group
    else
      current_group = current_group.new_group(part, part)
    end
  end
  
  current_group
end

def collect_all_files(directory, exclude_dirs = ['.git', 'node_modules', 'Pods', 'build'])
  files = {}
  
  Dir.glob("#{directory}/**/*", File::FNM_DOTMATCH).each do |path|
    next unless File.file?(path)
    
    # Skip excluded directories
    relative_path = Pathname.new(path).relative_path_from(Pathname.new(directory))
    next if exclude_dirs.any? { |ex| relative_path.to_s.start_with?(ex) }
    
    filename = File.basename(path)
    files[filename] ||= []
    files[filename] << path
  end
  
  files
end

# ============================================================
# Main Logic
# ============================================================

start_path = File.directory?(target_path) ? target_path : File.dirname(target_path)
xcodeproj_path = find_xcodeproj(start_path)
project = Xcodeproj::Project.open(xcodeproj_path)
project_root = Pathname.new(xcodeproj_path).parent

puts "📦 Using Xcode project: #{File.basename(xcodeproj_path)}"
puts "🔍 Scanning for broken references..."

# Collect all actual files in project
actual_files = collect_all_files(project_root.to_s)

# Find broken references
broken_refs = []
project.files.each do |file_ref|
  real_path = file_ref.real_path&.to_s
  
  # If real_path is nil or file doesn't exist, it's broken
  if real_path.nil? || !File.exist?(real_path)
    broken_refs << file_ref
  end
end

if broken_refs.empty?
  puts "✅ No broken references found! All references are valid."
  exit 0
end

puts "⚠️  Found #{broken_refs.size} broken reference(s)"

# Try to fix each broken reference
fixed_count = 0
unfixed_count = 0
unfixed_files = []

broken_refs.each do |file_ref|
  filename = file_ref.path ? File.basename(file_ref.path) : file_ref.display_name
  old_path = file_ref.real_path&.to_s
  
  # Try to find the file by name
  candidates = actual_files[filename]
  
  if candidates.nil? || candidates.empty?
    puts "❌ Cannot find: #{filename}"
    unfixed_count += 1
    unfixed_files << filename
    next
  end
  
  # Determine which candidate to use
  target_file = nil
  if candidates.size == 1
    target_file = candidates.first
  else
    # Multiple candidates - try to find the best match
    best_match = nil
    best_score = -1
    
    if old_path
      old_parts = old_path.split('/')
      
      candidates.each do |candidate|
        candidate_parts = candidate.split('/')
        
        # Calculate similarity score
        score = 0
        [old_parts.size, candidate_parts.size].min.times do |i|
          score += 1 if old_parts[-(i+1)] == candidate_parts[-(i+1)]
        end
        
        if score > best_score
          best_score = score
          best_match = candidate
        end
      end
    else
      best_match = candidates.first
    end
    
    target_file = best_match
  end
  
  next unless target_file
  
  # Get the directory and filename
  target_dir = File.dirname(target_file)
  target_filename = File.basename(target_file)
  
  # Find or create the group for the new location
  target_group = find_or_create_group(project, target_dir, project_root)
  
  # Get the old parent group
  old_parent = file_ref.parent
  
  # Remove from old parent
  if old_parent && old_parent.is_a?(Xcodeproj::Project::PBXGroup)
    old_parent.children.delete(file_ref)
  end
  
  # Set the file reference to just the filename
  file_ref.path = target_filename
  
  # Add to new parent group
  target_group.children << file_ref
  
  puts "✅ Fixed: #{filename}"
  puts "   Moved to: #{Pathname.new(target_file).relative_path_from(project_root)}"
  fixed_count += 1
end

# Clean up empty groups
def clean_empty_groups(group)
  return if group.nil?
  
  # Recursively clean child groups first
  group.groups.each do |child_group|
    clean_empty_groups(child_group)
  end
  
  # Remove this group if it's empty (no files and no child groups)
  if group.children.empty? && group.parent
    group.parent.children.delete(group)
  end
end

# Clean up empty groups in the project
puts ""
puts "🧹 Cleaning up empty groups..."
clean_empty_groups(project.main_group)

# Save the project
if fixed_count > 0
  project.save
  puts ""
  puts "💾 Saved Xcode project"
  puts "🎉 Fixed #{fixed_count} reference(s)"
end

if unfixed_count > 0
  puts ""
  puts "⚠️  Could not fix #{unfixed_count} reference(s):"
  unfixed_files.each { |f| puts "   - #{f}" }
end

puts ""
puts "✨ Done!"
