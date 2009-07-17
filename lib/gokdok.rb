require 'rake'
require 'rake/tasklib'
require 'grit'

module Gokdok
  
  # Create a new object in your Rakefile to set up the tasks. See the initialize method
  # for the options that you can pass in.
  #
  #  Gokdok::Dokker.new do |gd|
  #    gd.pages_home = 'gh-pages'
  #    gd.doc_home = 'doc'
  #    ...
  #  end
  class Dokker < Rake::TaskLib
    attr_accessor :git_path, :doc_home, :pages_home, :remote_path, :repo_url, :rdoc_task
    
    # Initialize the task. You may set the following properties
    # in the init block:
    #
    # [*git_path*] Path to the git binary. If unset, a system call will
    #              be used to find the binary. This will likely work on
    #              Unix-like systems but fail on Windows.
    # [*doc_home*] Path to the place where the RDoc documentation is created.
    #              Defaults to 'html'
    # [*pages_home*] Path were the repository with the gh-pages will be checked
    #                out to. Defaults to '.gh_pages'
    # [*remote_path*] Path in the remote repository where the RDoc will end up.
    #                 Defaults to 'html'
    # [*repo_url*] URL of the GIT repository that will be used. If unset, the
    #              Task will attempt to use the URL of the current "origin"
    #              branch.
    # [*rdoc_task*] The task that will be called to create the documentation.
    #               Defaults to :rdoc
    def initialize
      yield(self) if(block_given?)
      
      @git_path ||= find_git_binary
      @repo_url ||= find_repo_url
      
      @doc_home ||= 'html'
      @pages_home ||= '.gh_pages'
      @remote_path ||= 'html'
      @rdoc_task ||= :rdoc
      
      @doc_home = File.expand_path(doc_home)
      @pages_home = File.expand_path(pages_home)
      @home_dir = File.expand_path('.')
      
      define
    end
    
    private
    
    def find_git_binary
       `which git`.chop
    end
    
    def find_repo_url
      re = Regexp.new("^origin[\t|\s]+(.*)$")
      md = re.match(`#{git_path} remote -v`)
      raise(ArgumentError, "Cannot find out the repository URL.") unless(md)
      md[1]
    end
    
    def setup_gitignore
      print "Setting up the .gitignore file... "
      ignore_file = File.join(@home_dir, '.gitignore')
      ignore_line = File.basename(@pages_home)
      if(File.exists?(ignore_file))
        ignore_content = File.open(ignore_file) { |io| io.read }
        if(ignore_content.include?(ignore_line))
          puts "already set up"
        else
          File.open(ignore_file, 'a') { |io| io << ignore_line}
          puts "added to existing file"
        end
      else
        File.open(ignore_file, 'w') { |io| io <<  ignore_line }
        puts "created new"
      end
    end
    
    def checkout_pages
      puts 'Checking out the pages...'
      if(File.exists?(@pages_home))
        puts '-> Directory already exists. Not touching anything'
      else
        puts "-> Starting checkout of #{repo_url}"
        run_git_command("clone #{repo_url} #{pages_home}")
        puts '-> Repository cloned'
        Dir.chdir(@pages_home)
        branches = `#{git_path} branch -r`
        if(branches.include?('origin/gh-pages'))
          puts '-> Branch for gh-pages found, switching to it.'
          run_git_command("checkout --track -b gh-pages origin/gh-pages")
        else
          puts '-> No branch for gh-pages found, creating it.'
          run_git_command("symbolic-ref HEAD refs/heads/gh-pages")
          FileUtils.remove(File.join(@pages_home, '.git', 'index'))
          run_git_command('clean -fdx')
          puts '-> Clean branch created'
          File.open(File.join(@pages_home, 'index.html'), 'w') { |io| io << 'Automatic Page by Gokdok' }
          repo = Grit::Repo.new(@pages_home)
          repo.add('.')
          commit = repo.commit_all('Pages branch created by Gokdok')
          raise(RuntimeError, "Problem committing first revision") unless(commit)
        end
      end
    end
    
    def run_git_command(command)
      result = system("#{git_path} #{command}")
      raise(RuntimeError, "Could not run: git #{command}") unless(result)
    end
    
    def define
      namespace :gokdok do
        
        desc 'Show the settings for the Gok'
        task :settings do
          puts "GOKDOK Settings:"
          puts
          puts "Git binary: #{git_path}"
          puts "Git repository: #{repo_url}"
          puts "Generated RDoc in #{doc_home}"
          puts "GH-Pages in #{pages_home}"
          puts "Remote path: #{remote_path}"
          puts
        end
      
        desc 'Create the documentation without actually pushing it'
        task :update => rdoc_task do
          repo = Grit::Repo.new(pages_home)
          remote_dir = File.join(pages_home, remote_path)
          
          if(!remote_path || remote_path == '' || remote_path == '.' || remote_path == '/' || remote_path == './')
            puts "Deleting the old documentation in root #{pages_home}"
            Dir.chdir(pages_home)
            FileUtils.rm_rf(Dir['*'])
            puts "Copy the new documentation into place"
            FileUtils.cp_r(Dir["#{doc_home}/*"], remote_dir)
          else
            puts "Deleting the old documentation in #{remote_dir}"
            FileUtils.rm_rf(remote_dir)
            puts "Copy the new documentation into place"
            FileUtils.cp_r(doc_home, remote_dir)
          end
          
          repo.add('.')
          repo.commit_all('Committed new documentation set through Gokdok')
        end
      
        desc 'Create the new documentation and push it to the server'
        task :push => :update do
          Dir.chdir(pages_home)
          run_git_command('push origin gh-pages')
        end
        
        desc 'Create the new documentation, pull and push'
        task :pushplus => :update do
          Dir.chdir(pages_home)
          run_git_command('pull origin gh-pages')
          run_git_command('push origin gh-pages')
        end
      
        desc 'Initialize the Gokdok things.'
        task :init do
          setup_gitignore
          checkout_pages
        end
      end
      
      self
    end
    
    
  end
end