require 'pathname'

# Include hook code here
controller_path = File.join(directory, 'app', 'controllers')
$LOAD_PATH << controller_path
Dependencies.load_paths << controller_path
config.controller_paths << controller_path

#PROJECT_ROOT=FileUtils.pwd


require File.join(directory,'config','routes')