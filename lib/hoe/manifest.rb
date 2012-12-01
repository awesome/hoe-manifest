
# ruby stdlibs

require 'yaml'
require 'pp'
require 'logger'
require 'fileutils'
require 'pathname'


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
    end # task


    desc "Generate a #{name}.gemspec file"
    task 'manifest:gemspec' do
      File.open( "#{name}.gemspec", 'w' ) do |file|
        file.puts spec.to_ruby
      end
    end # task
    
    desc 'Create Manifest.tmp (for debugging check_manifest)'
    task 'manifest:tmp' do
      files = find_manifest_files()
        
      File.open( 'Manifest.tmp', 'w' ) do |file|
        file.puts files.join( "\n" )
      end
    end  # task
    
    desc 'Check manifest (follow symbolic links)'
    task 'manifest:check' do
      check_manifest_w_follow_sym_links()
    end  # task


  end # method define_manifest_tasks
  

##
# Verifies your Manifest.txt against the files in your project.

def find_manifest_files( root='.' )
  files = []
  with_config do |config, _|
    exclusions = config['exclude']

    puts "[hoe-manifest] exclude: >>#{exclusions}<<"

    ## NB: Find.find( '.' )  will NOT follow sym links
    ##  thus, use our own file finder -> find_all_files( '.' )

    find_all_files( root ).each do |path|
      if path =~ exclusions
        puts "[hoe-manifest] skipping path (exclude match): >>#{path}<<"
        next
      end
      files << path
    end
  end
  files = files.sort
end # method find_manifest_files


def check_manifest_w_follow_sym_links

    ## NB: assume DIFF is definded (included in standard debug hoe plugin)

    f = 'Manifest.tmp'
    files = find_manifest_files()

    File.open( f, 'w' ) { |fp| fp.puts files.join( "\n" ) }

    verbose = { :verbose => Rake.application.options.verbose }

    begin
      sh( "#{DIFF} -du Manifest.txt #{f}", verbose )
    ensure
      rm( f, verbose )
    end
    
end  # check_manifest_w_follow_sym_links


###############################################  
#### todo/fix: move somewhere else for reuse
##
##  move to manman gem !! why? why not?


def find_all_files( path )
  
  ## NB: Dir[ '**/*' ] and
  ##    Find.find( '.' )  do NOT follow symbolic links
  
  files = find_all_files_worker( Pathname.new(path), 0 )
  files = files.flatten
  ## convert from pathname back to plain strings
  files = files.map { |file| file.to_s }
end

def find_all_files_worker( path, depth )
  ## puts "#{' '*depth}find_all('#{path}')"

  files = path.children.map do |child|
    if child.file?
      child
    elsif child.directory?
      find_all_files_worker( child, depth+1 )
    else
      puts "*** warn: find_all_files - unknown pathname type (expected file|directory)"
    end
  end
  files
end



end # module Hoe::Manifest


# say hello
puts Hoe::Manifest.banner
