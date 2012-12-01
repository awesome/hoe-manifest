
# ruby stdlibs

require 'yaml'
require 'pp'
require 'logger'
require 'fileutils'


# our own code

require 'hoe/manifest/version'

class Hoe
  ## add an around filter for define_spec

  def define_spec_new
    puts "[hoe-manifest] before define_spec"
    spec_old = define_spec_old()
    puts "[hoe-manifest] after define_spec"
    
    ## add code here for after define_spec
    puts "[hoe-manifest] extra_manifest: >>#{extra_manifest}<<"
    
    puts "[hoe-manifest] spec.name:    >>#{spec.name}<<"
    puts "[hoe-manifest] spec.version: >>#{spec.version}<<"
    
    spec_old
  end

  alias_method :define_spec_old, :define_spec
  alias_method :define_spec,     :define_spec_new


  ## add an around filter for read_manifest
  
  def read_manifest_new
    puts "[hoe-manifest] before read_manifest"
    manifest_old = read_manifest_old()
    puts "[hoe-manifest] after read_manifest"
  
    manifest_old
  end

  alias_method :read_manifest_old, :read_manifest
  alias_method :read_manifest,     :read_manifest_new

end  # class Hoe


module Hoe::Manifest

  def self.banner
    "hoe-manifest plugin #{VERSION} / hoe #{Hoe::VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  ## attribute reader/writer (aka setter/getter)
  def extra_manifest
    @extra_manifest_path
  end

  def extra_manifest=(path)
    puts "[hoe-manifest] enter extra_manifest=('#{path}')"
    @extra_manifest_path = path
  end


  def initialize_manifest
    puts "[hoe-manifest] enter initialize_manifest"
  end

  def define_manifest_tasks
    puts "[hoe-manifest] enter define_manifest_tasks"
    
    # extend release task
    #  - e.g. make check_manifest required - check if is already required?
    task :release do
      puts "[hoe-manifest] hello from release task"
    end
    
    # extend check_manifest task
    task :check_manifest do
      puts "[hoe-manifest] hello from check_manifest task"
    end


    # define debug_manifest task
    desc "Debug manifest plugin for hoe"
    task 'manifest:debug' do
      puts "[hoe-manifest] hello from debug_manifest task"
      
      puts "[hoe-manifest] files:"
      pp spec.files
    
      puts "[hoe-manifest] extra_rdoc_files:"
      pp spec.extra_rdoc_files
    end


    desc "Generate a #{name}.gemspec file"
    task 'manifest:gemspec' do
      File.open( "#{name}.gemspec", 'w' ) do |file|
        file.puts spec.to_ruby
      end
    end
    
    desc 'Create Manifest.tmp (for debugging check_manifest)'
    task 'manifest:tmp' do
      require 'find'
      files = []
      with_config do |config, _|
        exclusions = config['exclude']

        puts "[hoe-manifest] exclude: >>#{exclusions}<<"

        Find.find( '.' ) do |path|
          unless File.file?( path )
            puts "[hoe-manifest] skipping path (not a file): >>#{path}<<"
            next
          end
          if path =~ exclusions
            puts "[hoe-manifest] skipping path (exclude match): >>#{path}<<"
            next
          end
          files << path[2..-1]
        end
        files = files.sort.join( "\n" )
        
        File.open( 'Manifest.tmp', 'w' ) do |file|
          file.puts files
        end
      end
    end  # task
    
  end # method define_manifest_tasks
  
end # module Hoe::Manifest


# say hello
puts Hoe::Manifest.banner
