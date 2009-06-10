require 'fileutils'

name ||=(File.dirname(__FILE__).split "/")[-1]
directory ||=File.expand_path(File.dirname(__FILE__))
PROJECT_ROOT=File.expand_path(File.join(directory,'..','..', '..'))
puts "installing plugin #{name}"
puts "checking project directories #{PROJECT_ROOT} #{directory}"


b_views_exists=FileTest.directory?(File.join(PROJECT_ROOT, 'app', 'views', 'content'))
b_js_content_exists=FileTest.directory?(File.join(PROJECT_ROOT, 'public', 'javascripts','content'))
b_css_content_exists=FileTest.directory?(File.join(PROJECT_ROOT, 'public', 'stylesheets','content'))
b_layout_exists=FileTest.file?(File.join(PROJECT_ROOT, 'app', 'views','layouts','content.rhtml'))
b_helper_exists=FileTest.file?(File.join(PROJECT_ROOT, 'app', 'helpers','content_permissions_helper.rb'))

if b_views_exists || b_js_content_exists || b_css_content_exists || b_layout_exists || b_helper_exists
  puts "#{File.join(PROJECT_ROOT, 'app', 'views','content')} already exists" if b_views_exists
  puts "#{File.join(PROJECT_ROOT, 'public', 'javascripts','content')} already exists" if b_js_content_exists
  puts "#{File.join(PROJECT_ROOT, 'public', 'stylesheets','content')} already exists" if b_css_content_exists
  puts "#{File.join(PROJECT_ROOT, 'app', 'views','layouts','content.rhtml')} already exists" if b_layout_exists
  puts "#{File.join(PROJECT_ROOT, 'app', 'helpers','content_permissions_helper.rb')} already exists" if b_helper_exists
  puts "Plugin install aborted. Please remove the existing directories before trying to reinstall"  
  exit(-1)
end  




FileUtils.cp_r(File.join(directory,'app', 'views','content'),File.join(PROJECT_ROOT,'app', 'views'))
puts "Copying dir " + File.join(PROJECT_ROOT, 'app', 'views', 'content')
FileUtils.cp_r(File.join(directory, 'public', 'javascripts','content'),File.join(PROJECT_ROOT, 'public', 'javascripts'))
puts "Copying dir " + File.join(PROJECT_ROOT, 'public', 'javascripts', 'content')
FileUtils.cp_r(File.join(directory, 'public', 'stylesheets','content'),File.join(PROJECT_ROOT, 'public', 'stylesheets'))
puts "Copying dir " + File.join(PROJECT_ROOT, 'public', 'stylesheets', 'content')
FileUtils.cp_r(File.join(directory, 'public', 'javascripts','fckcustom.js.content.example'),File.join(PROJECT_ROOT, 'public', 'javascripts'))
puts "Copying file " + File.join(PROJECT_ROOT, 'public', 'javascripts', 'fckcustom.js.content.example' )
FileUtils.cp_r(File.join(directory, 'public', 'javascripts','fckstyles.xml.content.example'),File.join(PROJECT_ROOT, 'public', 'javascripts'))
puts "Copying file " + File.join(PROJECT_ROOT, 'public', 'javascripts', 'fckstyles.xml.content.example' )
FileUtils.cp_r(File.join(directory, 'public', 'javascripts','fcktemplates.xml.content.example'),File.join(PROJECT_ROOT, 'public', 'javascripts'))
puts "Copying file " + File.join(PROJECT_ROOT, 'public', 'javascripts', 'fcktemplates.xml.content.example' )

FileUtils.cp_r(File.join(directory, 'app', 'views','layouts','content.rhtml'),File.join(PROJECT_ROOT, 'app', 'views','layouts'))
puts "Copying file " + File.join(PROJECT_ROOT, 'app', 'views', 'layouts', 'content.rhtml' )
FileUtils.cp_r(File.join(directory, 'lib', 'content_permissions_helper.rb.example'),File.join(PROJECT_ROOT, 'app', 'helpers'))
puts "Copying file " + File.join(PROJECT_ROOT, 'app', 'helpers','content_permissions_helper.rb.example')


puts "checking prototype-windows xilinus directories"
b_js_windows_exists=FileTest.directory?(File.join(PROJECT_ROOT, 'public', 'javascripts','windows'))
b_css_windows_exists=FileTest.directory?(File.join(PROJECT_ROOT, 'public', 'stylesheets','windows'))
b_install_windows_library=true
if b_js_windows_exists || b_css_windows_exists
   puts "/public/javascripts/windows directory already exists" if b_js_windows_exists
   puts "/public/stylesheets/windows directory already exists" if b_css_windows_exists
   puts "These directories are used in this plugin for the library http://prototype-window.xilinus.com/"
   puts "please confirm you want to overwrite the matching files (type 'yes' to confirm, or anything else to skip)"
    s_answer=$stdin.gets
    if s_answer.chomp == 'yes'
      puts "overwriting windows contents"
    else
      puts "install of windows xilinus library skipped. Current version will be used"
      b_install_windows_library=false
     end   
end

if b_install_windows_library
  FileUtils.cp_r(File.join(directory, 'public', 'javascripts','windows'),File.join(PROJECT_ROOT, 'public', 'javascripts'))
  FileUtils.cp_r(File.join(directory, 'public', 'stylesheets','windows'),File.join(PROJECT_ROOT, 'public', 'stylesheets'))
end  

puts IO.read(File.join(File.dirname(__FILE__), 'README'))
