require 'rubygems'
require 'octokit'
require 'optparse'
require './github.rb'
require './models/issue.rb'

class Nagnagnag 
   def initialize
      @options = parse_options
      @client = Github.api
   end

   def github
      @client
   end

   def nagnagnag
      me = Github::config("github.user")
      Issue.old_issues(@options[:repo]).each do |issue|
         if issue.last_comment_was_by(me)
            issue.close
         else
            issue.comment_on_issue()
         end
      end
   end

   def parse_options
      options = {
         :repo => nil,
         :no_activity_days => 30,
         :close_after_days => 30,
         :exempt_label => "stay open"
      }

      @options = OptionParser.new do |opts|
         opts.banner = "Usage: nagnagnag --repo=user/repo"
       
         opts.on("-r", "--repo [REPO]", "github  username/repository") do |v|
            options[:repo] = v.split('/')
         end

         opts.on("--no-activity-days=DAYS", OptionParser::DecimalInteger,
                       "Number of days to wait after the last activity",
                       "on an issue before commenting.") do |v|
            options[:no_activity_days] = v
         end

         opts.on("--close-after-days=DAYS", OptionParser::DecimalInteger,
                       "Number of days to wait after the last comment",
                       "from this bot before closing an issue.") do |v|
            options[:close_after_days] = v
         end

         opts.on("--exempt-label=LABEL", String,
                       "Name of issue label that will prevent issues",
                       "from being examined or modified by this bot.") do |v|
            options[:close_after_days] = v
         end

         opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
         end

         if options[:repo].nil? 
            puts opts
            exit 1
         end
      end.parse!
      options
   end
end

Nagnagnag.new.nagnagnag
