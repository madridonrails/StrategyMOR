# Uninstall hook code here
require 'fileutils'
 
name ||=(File.dirname(__FILE__).split "/")[-1]
directory ||=File.dirname(__FILE__)
PROJECT_ROOT=File.join(directory,'..','..', '..')

puts "if you don't remove the tables created by the plugin, they will not be deleted"
puts "you can use the following task in order to remove them"
puts "  rake content:delete_database\n\n\n"
puts "please confirm you already deleted the tables and want to proceed with uninstall (type 'yes' to confirm, or anything else to skip)"

s_answer=$stdin.gets
exit(-1) unless s_answer.chomp == 'yes'
      
puts "please confirm you want to delete the installation files and the content templates (type 'yes' to confirm, or anything else to skip)"
s_answer=$stdin.gets
if s_answer.chomp == 'yes'
  puts "deleting files and directories"
  FileUtils.rm_rf File.join(PROJECT_ROOT, 'app', 'views', 'content')
  FileUtils.rm_rf File.join(PROJECT_ROOT, 'public', 'javascripts', 'content')
  FileUtils.rm_rf File.join(PROJECT_ROOT, 'public', 'stylesheets', 'content')
  FileUtils.rm_rf File.join(PROJECT_ROOT, 'public', 'javascripts', 'windows')
  FileUtils.rm_rf File.join(PROJECT_ROOT, 'public', 'stylesheets', 'windows')
  FileUtils.rm_f File.join(PROJECT_ROOT, 'app', 'views','layouts','content.rhtml')
  FileUtils.rm_f File.join(PROJECT_ROOT, 'public', 'javascripts','fckcustom.js.content.example')
  File.join(PROJECT_ROOT, 'app', 'helpers','content_permissions_helper.rb')
else
  puts "deleted skipped"
end   

