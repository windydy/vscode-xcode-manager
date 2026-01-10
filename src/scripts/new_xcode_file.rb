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
  puts "Usage: ruby new_xcode_file.rb <file_name> <base_class> <output_dir> <template_root> [template_type] [file_type] [class_name]"
  exit 1
end

file_name = ARGV[0]
base_class = ARGV[1]
output_dir = ARGV[2]
template_root = ARGV[3]
template_type = ARGV[4] || 'cocoa_touch'  # default to cocoa_touch for backward compatibility
file_type = ARGV[5] || ''  # For objc_file: empty, category, extension, protocol
class_name = ARGV[6] || ''  # For category/extension: the class to extend

# ============================================================
# Helpers
# ============================================================

def valid_class_name?(name)
  name =~ /^[A-Z][A-Za-z0-9_]*$/
end

def get_system_framework_import(class_name)
  # Determine import statement based on class name prefix
  # Apple frameworks follow consistent naming conventions
  case class_name
    # UIKit - iOS/iPadOS UI components
    when /^UI/
      '<UIKit/UIKit.h>'
    
    # Foundation - Basic data types and collections
    when /^NS/
      '<Foundation/Foundation.h>'
    
    # Graphics & Animation
    when /^CG/
      '<CoreGraphics/CoreGraphics.h>'
    when /^CA/
      '<QuartzCore/QuartzCore.h>'
    when /^CI/
      '<CoreImage/CoreImage.h>'
    
    # Web & Networking
    when /^WK/
      '<WebKit/WebKit.h>'
    when /^NW/
      '<Network/Network.h>'
    when /^NE/
      '<NetworkExtension/NetworkExtension.h>'
    
    # Media & Audio/Video
    when /^AV/
      '<AVFoundation/AVFoundation.h>'
    when /^MP/
      '<MediaPlayer/MediaPlayer.h>'
    when /^CV/
      '<CoreVideo/CoreVideo.h>'
    
    # Maps & Location
    when /^MK/
      '<MapKit/MapKit.h>'
    when /^CL/
      '<CoreLocation/CoreLocation.h>'
    
    # AR & 3D
    when /^AR/
      '<ARKit/ARKit.h>'
    when /^SC/
      '<SceneKit/SceneKit.h>'
    when /^MDL/
      '<ModelIO/ModelIO.h>'
    
    # Gaming
    when /^SK(?:Scene|Node|Action|Texture|View|Sprite|Shader|Constraint)/
      '<SpriteKit/SpriteKit.h>'
    when /^GK/
      '<GameKit/GameKit.h>'
    when /^RP/
      '<ReplayKit/ReplayKit.h>'
    
    # Metal & GPU
    when /^MTL/, /^MTK/
      '<MetalKit/MetalKit.h>'
    when /^GL/
      '<GLKit/GLKit.h>'
    
    # Machine Learning & AI
    when /^ML/
      '<CoreML/CoreML.h>'
    when /^VN/
      '<Vision/Vision.h>'
    when /^SN/
      '<SoundAnalysis/SoundAnalysis.h>'
    
    # User Data & Services
    when /^PK/
      '<PassKit/PassKit.h>'
    when /^HK/
      '<HealthKit/HealthKit.h>'
    when /^HM/
      '<HomeKit/HomeKit.h>'
    when /^CK/
      '<CloudKit/CloudKit.h>'
    when /^CN/
      '<Contacts/Contacts.h>'
    when /^PH/
      '<Photos/Photos.h>'
    when /^EK/
      '<EventKit/EventKit.h>'
    
    # Communication
    when /^MF/
      '<MessageUI/MessageUI.h>'
    when /^UN/
      '<UserNotifications/UserNotifications.h>'
    when /^CT(?:Call|Telephony|Carrier)/
      '<CoreTelephony/CoreTelephony.h>'
    
    # Text & Fonts
    when /^CT(?!Call|Telephony|Carrier)/
      '<CoreText/CoreText.h>'
    when /^PDF/
      '<PDFKit/PDFKit.h>'
    
    # Motion & Sensors
    when /^CM(?:Accelerometer|Gyro|Magnetometer|Motion|Pedometer|Altimeter)/
      '<CoreMotion/CoreMotion.h>'
    
    # Core Data & Persistence
    when /^CM(?!Accelerometer|Gyro|Magnetometer|Motion|Pedometer|Altimeter)/, /^NSManaged/, /^NSPersistent/, /^NSFetch/
      '<CoreData/CoreData.h>'
    
    # Bluetooth & Connectivity
    when /^CB/
      '<CoreBluetooth/CoreBluetooth.h>'
    when /^EAAccessory/
      '<ExternalAccessory/ExternalAccessory.h>'
    when /^NFC/
      '<CoreNFC/CoreNFC.h>'
    
    # Authentication & Security
    when /^LA/
      '<LocalAuthentication/LocalAuthentication.h>'
    when /^Sec/, /^CF(?:Data|String|Array|Dictionary|Number|Boolean|Date|URL)/
      '<Security/Security.h>'
    when /^DC/
      '<DeviceCheck/DeviceCheck.h>'
    
    # Search & Indexing
    when /^CS/
      '<CoreSpotlight/CoreSpotlight.h>'
    
    # Safari & Web Services
    when /^SF(?:Safari|Content|AuthenticationSession)/
      '<SafariServices/SafariServices.h>'
    when /^SF(?:Speech)/
      '<Speech/Speech.h>'
    when /^SF(?!Safari|Content|AuthenticationSession|Speech)/
      '<SafariServices/SafariServices.h>'
    
    # Intents & Siri
    when /^IN/
      '<Intents/Intents.h>'
    
    # StoreKit & Purchases
    when /^SK(?:Product|Payment|Receipt|Request|Transaction|Store|Cloud)/
      '<StoreKit/StoreKit.h>'
    
    # Social & Accounts (deprecated but still used)
    when /^SL/
      '<Social/Social.h>'
    when /^AC/
      '<Accounts/Accounts.h>'
    
    # Advertising & Analytics
    when /^AS/
      '<AdSupport/AdSupport.h>'
    
    # Widgets & Extensions
    when /^NC/
      '<NotificationCenter/NotificationCenter.h>'
    
    # WatchKit & watchOS
    when /^WK(?!WebView)/, /^HM/
      '<WatchKit/WatchKit.h>'
    
    # CarPlay
    when /^CP/
      '<CarPlay/CarPlay.h>'
    
    # Background Tasks
    when /^BG/
      '<BackgroundTasks/BackgroundTasks.h>'
    
    # System & IOKit (macOS)
    when /^IO/
      '<IOKit/IOKit.h>'
    when /^CW/
      '<CoreWLAN/CoreWLAN.h>'
    
    else
      "\"#{class_name}.h\""  # Custom class
  end
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

# For category/extension, file_name is the category/extension name and can be flexible
# Only validate strictly for other types
if template_type == 'objc_file' && (file_type == 'category' || file_type == 'extension')
  # For category/extension, just check basic validity
  abort "❌ Invalid file name: #{file_name}" unless file_name =~ /^[A-Za-z][A-Za-z0-9_]*$/
else
  # For other types, require uppercase start (class name convention)
  abort "❌ Invalid file name: #{file_name}" unless valid_class_name?(file_name)
end

# For cocoa_touch template, validate base_class if provided
if template_type == 'cocoa_touch' && !base_class.empty?
  abort "❌ Invalid base class: #{base_class}" unless valid_class_name?(base_class)
end

# ============================================================
# Generate Files
# ============================================================

# Determine template directory based on template type and file type
case template_type
when 'cocoa_touch'
  # Try to find specific template for the base class, otherwise use NSObject as fallback
  specific_template = File.join(template_root, 'objc', 'cocoa_touch', base_class)
  if Dir.exist?(specific_template)
    template_dir = specific_template
  else
    # Use NSObject template as fallback for custom base classes
    template_dir = File.join(template_root, 'objc', 'cocoa_touch', 'NSObject')
    puts "ℹ️  Using NSObject template for custom base class: #{base_class}"
  end
when 'objc_file'
  case file_type
  when 'empty'
    template_dir = File.join(template_root, 'objc', 'objc_file')
  when 'category'
    template_dir = File.join(template_root, 'objc', 'objc_file', 'category')
  when 'extension'
    template_dir = File.join(template_root, 'objc', 'objc_file', 'extension')
  when 'protocol'
    template_dir = File.join(template_root, 'objc', 'objc_file', 'protocol')
  else
    abort "❌ Unknown file type: #{file_type}"
  end
when 'header_file'
  template_dir = File.join(template_root, 'objc', 'header_file')
else
  abort "❌ Unknown template type: #{template_type}"
end

abort "❌ Template not found: #{template_dir}" unless Dir.exist?(template_dir)

FileUtils.mkdir_p(output_dir)

generated_files = []

# Get user info
username = ENV['USER'] || 'Unknown'
current_date = Time.now.strftime('%-m/%-d/%y')
current_year = Time.now.year

# Extract project name from xcodeproj path
xcodeproj_path = find_xcodeproj(output_dir)
project_name = File.basename(xcodeproj_path, '.xcodeproj')

Dir.glob("#{template_dir}/*").each do |tpl|
  # For category, use ClassName+CategoryName format
  if file_type == 'category'
    base_filename = "#{class_name}+#{file_name}"
    filename = File.basename(tpl).gsub("___FILEBASENAME___", base_filename)
  else
    filename = File.basename(tpl).gsub("___FILEBASENAME___", file_name)
  end
  
  # Read template and replace all placeholders
  # For category, FILEBASENAME should be ClassName+CategoryName
  filebasename_replacement = (file_type == 'category') ? "#{class_name}+#{file_name}" : file_name
  
  content = File.read(tpl)
    .gsub("___FILEBASENAME___", filebasename_replacement)
    .gsub("___FILENAME___", filename)
    .gsub("___PROJECTNAME___", project_name)
    .gsub("___FULLUSERNAME___", username)
    .gsub("___DATE___", current_date)
    .gsub("___COPYRIGHT___", "Copyright © #{current_year} #{username}. All rights reserved.")
  
  # For category: replace CLASSNAME and CATEGORYNAME
  if file_type == 'category'
    import_statement = get_system_framework_import(class_name)
    
    content = content
      .gsub("#import \"___CLASSNAME___.h\"", "#import #{import_statement}")
      .gsub("___CLASSNAME___", class_name)
      .gsub("___CATEGORYNAME___", file_name)
  # For extension: replace CLASSNAME
  elsif file_type == 'extension'
    content = content.gsub("___CLASSNAME___", class_name)
  # For cocoa_touch: replace base class import
  elsif template_type == 'cocoa_touch'
    base_class_import = get_system_framework_import(base_class)
    # Replace the hardcoded import in templates with the correct one
    content = content
      .gsub(/<UIKit\/UIKit\.h>/, base_class_import)
      .gsub(/<Foundation\/Foundation\.h>/, base_class_import)
      # Replace base class name in templates (handles NSObject, UIViewController, etc.)
      .gsub(/: UIViewController\b/, ": #{base_class}")
      .gsub(/: UIView\b/, ": #{base_class}")
      .gsub(/: UITableViewCell\b/, ": #{base_class}")
      .gsub(/: NSObject\b/, ": #{base_class}")
  end
  
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
