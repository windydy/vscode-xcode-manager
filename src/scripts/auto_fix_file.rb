#!/usr/bin/env ruby
# VS Code Extension - auto_fix_file.rb
# Auto-fix a specific file reference after it's moved

require 'xcodeproj'
require 'pathname'
require 'json'

if ARGV.size < 2
  puts JSON.generate({success: false, error: "Usage: ruby auto_fix_file.rb <file_path> <operation>"})
  exit 1
end

file_path = ARGV[0]
operation = ARGV[1] # 'moved', 'deleted', 'created'

# ============================================================
# Helpers
# ============================================================

def find_xcodeproj(start_dir)
  current = Pathname.new(start_dir).expand_path
  
  temp = current
  while !temp.root?
    xcodeproj_files = Dir.glob("#{temp}/*.xcodeproj")
    return xcodeproj_files.first if xcodeproj_files.any?
    temp = temp.parent
  end
  
  xcodeproj_files = Dir.glob("#{current}/**/*.xcodeproj")
  return xcodeproj_files.first if xcodeproj_files.any?
  
  nil
end

def find_file_references_by_name(project, filename)
  references = []
  project.files.each do |file_ref|
    ref_filename = file_ref.path ? File.basename(file_ref.path) : file_ref.display_name
    if ref_filename == filename
      references << file_ref
    end
  end
  references
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

def clean_empty_groups(group)
  return if group.nil?
  
  group.groups.each do |child_group|
    clean_empty_groups(child_group)
  end
  
  if group.children.empty? && group.parent
    group.parent.children.delete(group)
  end
end

# ============================================================
# Main Logic
# ============================================================

result = {success: false, operation: operation, file: file_path}

begin
  is_directory = File.directory?(file_path)
  
  xcodeproj_path = find_xcodeproj(is_directory ? file_path : File.dirname(file_path))
  
  unless xcodeproj_path
    result[:error] = "No .xcodeproj found"
    puts JSON.generate(result)
    exit 0
  end
  
  project = Xcodeproj::Project.open(xcodeproj_path)
  project_root = Pathname.new(xcodeproj_path).parent
  
  case operation
  when 'moved'
    # Handle both file and folder moves
    files_to_fix = []
    
    if is_directory && File.exist?(file_path)
      # Collect all files in the directory
      Dir.glob("#{file_path}/**/*").each do |f|
        files_to_fix << f if File.file?(f)
      end
    elsif !is_directory && File.exist?(file_path)
      # Single file
      files_to_fix << file_path
    else
      result[:error] = "Path does not exist"
      puts JSON.generate(result)
      exit 0
    end
    
    if files_to_fix.empty?
      result[:message] = "No files to fix"
      result[:success] = true
      puts JSON.generate(result)
      exit 0
    end
    
    fixed_count = 0
    
    files_to_fix.each do |target_file|
      filename = File.basename(target_file)
      file_refs = find_file_references_by_name(project, filename)
      
      next if file_refs.empty?
      
      file_refs.each do |file_ref|
        old_real_path = file_ref.real_path&.to_s
        
        # Skip if already pointing to correct location
        next if old_real_path == target_file
        
        # Find target group
        target_dir = File.dirname(target_file)
        target_group = find_or_create_group(project, target_dir, project_root)
        
        # Remove from old parent
        old_parent = file_ref.parent
        if old_parent && old_parent.is_a?(Xcodeproj::Project::PBXGroup)
          old_parent.children.delete(file_ref)
        end
        
        # Update reference
        file_ref.path = filename
        target_group.children << file_ref
        
        fixed_count += 1
      end
    end
    
    if fixed_count > 0
      # Clean up empty groups
      clean_empty_groups(project.main_group)
      
      project.save
      result[:success] = true
      result[:message] = "Fixed #{fixed_count} reference(s)"
    else
      result[:success] = true
      result[:message] = "No references needed fixing"
    end
    
  when 'deleted'
    # File was deleted, already handled by remove script
    result[:message] = "Delete operation - no auto-fix needed"
    result[:success] = true
    
  when 'created'
    # File was created, already handled by add script
    result[:message] = "Create operation - no auto-fix needed"
    result[:success] = true
    
  else
    result[:error] = "Unknown operation: #{operation}"
  end
  
rescue => e
  result[:error] = e.message
  result[:backtrace] = e.backtrace[0..2] if e.backtrace
ensure
  # Always output JSON, even on error
  puts JSON.generate(result)
end
