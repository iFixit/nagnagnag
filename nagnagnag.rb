require 'rubygems'
require 'octokit'
require 'github.rb'

Octokit.auto_traversal = true

class Nagnagnag 
   def initialize
      @client = Github.api
   end

   def parse_options
      @options = OptionParser.new do |opts|
         opts.banner = "Usage: nagnagnag --repo=user/repo"
       
         opts.on("-r", "--repo [REPO]", "github  username/repository") do |v|
            options[:repo] = v.split('/')
         end
      end.parse!
   end
end

class Options
   def initialze
   end
end

