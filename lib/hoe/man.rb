
# ruby stdlibs

require 'yaml'
require 'pp'
require 'logger'
require 'fileutils'


# our own code

require 'hoe/man/version'

module Hoe::Man

  def self.banner
    "hoe-man #{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  ## attribute reader/writer (aka setter/getter)
  def extra_manifest
    @extra_manifest_path
  end

  def extra_manifest=(path)
    puts "[debug] enter extra_manifest=(#{path})"
    @extra_manifest_path = path
    
    puts "[debug] files:"
    pp self.files
    
    puts "[debug] extra_rdoc_files:"
    pp self.extra_rdoc_files
  end

  def initialize_man
    puts "[debug] enter initialize_man"
  end

  def define_man_tasks
    puts "[debug] enter define_man_tasks"
  end
  
end # module Hoe::Man



# say hello
puts Hoe::Man.banner


