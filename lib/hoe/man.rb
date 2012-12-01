
# ruby stdlibs

require 'yaml'
require 'pp'
require 'logger'
require 'fileutils'


# our own code

require 'hoe/man/version'

class Hoe
  ## add an around filter around define_spec

  def define_spec_new
    puts "[hoe-man] before define_spec"
    define_spec_old()
    puts "[hoe-man] after define_spec"
    
    ## add code here for after define_spec
    puts "[hoe-man] extra_manifest: #{extra_manifest}"
    
    puts "[hoe-man] spec.name:    #{spec.name}"
    puts "[hoe-man] spec.version: #{spec.version}"
  end

  alias_method :define_spec_old, :define_spec
  alias_method :define_spec,     :define_spec_new

end

module Hoe::Man

  def self.banner
    "hoe-man plugin #{VERSION} / hoe #{Hoe::VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  ## attribute reader/writer (aka setter/getter)
  def extra_manifest
    @extra_manifest_path
  end

  def extra_manifest=(path)
    puts "[hoe-man] enter extra_manifest=('#{path}')"
    @extra_manifest_path = path
  end


  def initialize_man
    puts "[hoe-man] enter initialize_man"
  end

  def define_man_tasks
    puts "[hoe-man] enter define_man_tasks"
    
    # extend release task
    #  - e.g. make check_manifest required - check if is already required?
    task :release do
      puts "[hoe-man] hello from release task"
    end
    
    # extend check_manifest task
    task :check_manifest do
      puts "[hoe-man] hello from check_manifest task"
    end

    # define debug-man task
    desc "Debug man plugin for hoe [from hoe-man plugin]"
    task :debug_man do
      puts "[hoe-man] hello from debug_man task"
      
      puts "[hoe-man] files:"
      pp spec.files
    
      puts "[hoe-man] extra_rdoc_files:"
      pp spec.extra_rdoc_files
    end

    if Rake::Task.tasks.find { |t| t.name == 'gemspec' }
      puts "*** warn: [hoe-man] gemspec task already defined; returning"
      return
    end
    
    desc "Generate a #{name}.gemspec file [from hoe-man plugin]"
    task :gemspec do
      File.open("#{name}.gemspec", "w") do |file|
        file.puts spec.to_ruby
      end
    end
    
  end
  
end # module Hoe::Man



# say hello
puts Hoe::Man.banner
