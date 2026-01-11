#!/usr/bin/env ruby
# VS Code Extension - remove_from_xcodeproj.rb
# Remove files/folders from Xcode project

require 'fileutils'
require 'xcodeproj'
require 'pathname'

# ============================================================
# Parse command-line arguments
# ============================================================

if ARGV.size < 2
  puts "Usage: ruby remove_from_xcodeproj.rb <path> <mode>"
  puts "  path: File or folder path to remove"
  puts "  mode: 'reference' (remove from Xcode only) or 'trash' (remove from Xcode and delete file)"
  exit 1
end

target_path = ARGV[0]
mode = ARGV[1] || 'reference'

unless ['reference', 'trash'].include?(mode)
  abort "❌ Invalid mode: #{mode}. Use 'reference' or 'trash'"
end

unless File.exist?(target_path)
  abort "❌ Path does not exist: #{target_path}"
end

# ============================================================
# Helpers
# ============================================================

def find_xcodeproj(start_dir)
  puts "🔍 Searching for .xcodeproj file starting from: #{start_dir}"
  current = Pathname.new(start_dir).expand_path
  
  # 首先检查当前目录及子目录
  xcodeproj_files = Dir.glob("#{current}/**/*.xcodeproj", File::FNM_CASEFOLD)
  puts "🔍 Found #{xcodeproj_files.length} .xcodeproj files in current directory and subdirectories: #{xcodeproj_files}"
  return xcodeproj_files.first if xcodeproj_files.any?
  
  # 向上搜索更多层级（从5层增加到10层）
  original_current = current
  10.times do |level|
    puts "🔍 Checking level #{level} at path: #{current}"
    xcodeproj_files = Dir.glob("#{current}/**/*.xcodeproj", File::FNM_CASEFOLD)
    puts "🔍 Found #{xcodeproj_files.length} .xcodeproj files at this level"
    return xcodeproj_files.first if xcodeproj_files.any?
    
    break if current.root?
    current = current.parent
    puts "🔍 Going up to parent: #{current}"
  end
  
  # 如果还是找不到，尝试在更广范围搜索
  # 检查常见项目根目录位置
  possible_roots = [
    "#{original_current}/../..",
    "#{original_current}/../../..",
    "#{Dir.pwd}"  # 当前工作目录
  ]
  
  possible_roots.each do |root|
    root_path = Pathname.new(root).expand_path
    puts "🔍 Checking possible root: #{root_path}"
    if File.exist?(root_path)
      xcodeproj_files = Dir.glob("#{root_path}/**/*.xcodeproj", File::FNM_CASEFOLD)
      puts "🔍 Found #{xcodeproj_files.length} .xcodeproj files in possible root: #{xcodeproj_files}"
      return xcodeproj_files.first if xcodeproj_files.any?
    else
      puts "🔍 Skipping non-existent root: #{root_path}"
    end
  end
  
  abort "❌ No .xcodeproj found in #{start_dir} or its parent directories."
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

def remove_file_from_project(project, file_path)
  file_refs = find_file_references(project, file_path)
  
  if file_refs.empty?
    puts "⚠️  File not found in project: #{File.basename(file_path)}"
    return false
  end
  
  file_refs.each do |file_ref|
    # Remove from all build phases
    project.targets.each do |target|
      # Check if target responds to the specific build phase methods
      if target.respond_to?(:source_build_phase) && !target.source_build_phase.nil?
        target.source_build_phase.files.each do |build_file|
          if build_file.file_ref == file_ref
            build_file.remove_from_project
          end
        end
      end
      
      if target.respond_to?(:resources_build_phase) && !target.resources_build_phase.nil?
        target.resources_build_phase.files.each do |build_file|
          if build_file.file_ref == file_ref
            build_file.remove_from_project
          end
        end
      end
      
      if target.respond_to?(:frameworks_build_phase) && !target.frameworks_build_phase.nil?
        target.frameworks_build_phase.files.each do |build_file|
          if build_file.file_ref == file_ref
            build_file.remove_from_project
          end
        end
      end
    end
    
    # Remove the file reference
    file_ref.remove_from_project
    puts "✅ Removed from Xcode: #{File.basename(file_path)}"
  end
  
  true
end

def remove_group_from_project(project, group_path)
  group_name = File.basename(group_path)
  
  def find_group_by_path(parent, path_parts)
    return parent if path_parts.empty?
    
    next_part = path_parts.first
    child_group = parent.groups.find { |g| g.display_name == next_part || g.path == next_part }
    
    return nil unless child_group
    find_group_by_path(child_group, path_parts[1..-1])
  end
  
  # Try to find the group
  project_root = Pathname.new(find_xcodeproj(group_path)).parent
  relative_path = Pathname.new(group_path).relative_path_from(project_root)
  path_parts = relative_path.each_filename.to_a
  
  group = find_group_by_path(project.main_group, path_parts)
  
  if group.nil?
    puts "⚠️  Group not found in project: #{group_name}"
    return false
  end
  
  # Remove all file references in this group recursively
  def remove_all_files_in_group(group, project)
    group.files.each do |file_ref|
      # Remove from all build phases
      project.targets.each do |target|
        # Check if target responds to the specific build phase methods
        phases_to_check = []
        
        if target.respond_to?(:source_build_phase) && !target.source_build_phase.nil?
          phases_to_check << target.source_build_phase
        end
        
        if target.respond_to?(:resources_build_phase) && !target.resources_build_phase.nil?
          phases_to_check << target.resources_build_phase
        end
        
        if target.respond_to?(:frameworks_build_phase) && !target.frameworks_build_phase.nil?
          phases_to_check << target.frameworks_build_phase
        end
        
        phases_to_check.each do |phase|
          phase.files.each do |build_file|
            if build_file.file_ref == file_ref
              build_file.remove_from_project
            end
          end
        end
      end
      
      file_ref.remove_from_project
    end
    
    # Recursively remove files in subgroups
    group.groups.each do |subgroup|
      remove_all_files_in_group(subgroup, project)
    end
  end
  
  remove_all_files_in_group(group, project)
  
  # Remove the group itself
  group.remove_from_project
  puts "✅ Removed group from Xcode: #{group_name}"
  
  true
end

# ============================================================
# Main Logic
# ============================================================

is_directory = File.directory?(target_path)
xcodeproj_path = find_xcodeproj(target_path)

puts "📦 Opening Xcode project: #{File.basename(xcodeproj_path)}"
project = Xcodeproj::Project.open(xcodeproj_path)

# Remove from Xcode project
if is_directory
  puts "📁 Removing folder from Xcode: #{File.basename(target_path)}"
  remove_group_from_project(project, target_path)
else
  puts "📄 Removing file from Xcode: #{File.basename(target_path)}"
  remove_file_from_project(project, target_path)
end

# Save the project
project.save
puts "💾 Xcode project saved"

# Delete from filesystem if mode is 'trash'
if mode == 'trash'
  puts "🗑️  Moving to trash..."
  
  # Use macOS trash command
  begin
    system('osascript', '-e', "tell application \"Finder\" to delete POSIX file \"#{target_path}\"")
    
    if $?.success?
      puts "✅ Moved to trash: #{File.basename(target_path)}"
    else
      # Fallback to FileUtils.rm_rf if trash command fails
      if is_directory
        FileUtils.rm_rf(target_path)
      else
        FileUtils.rm_f(target_path)
      end
      puts "✅ Deleted: #{File.basename(target_path)}"
    end
  rescue => e
    puts "⚠️  Failed to move to trash, deleting directly: #{e.message}"
    if is_directory
      FileUtils.rm_rf(target_path)
    else
      FileUtils.rm_f(target_path)
    end
    puts "✅ Deleted: #{File.basename(target_path)}"
  end
end

puts "🎉 Done!"



