require 'rubygems'
require 'octokit'
require 'optparse'
require './github.rb'
require './models/issue.rb'
require './models/comment.rb'
require './log.rb'
require './config.rb'

class Nagnagnag 
   attr_accessor :config

   def initialize
      @client = Github.api
      @@instance = self
   end

   def self.config
      @config ||= Config.from_commandline
   end

   def github
      @client
   end

   def nagnagnag
      me = Github::config("github.user")
      Issue.old_issues(self.config.repo).each do |issue|
         Log.debug "Looking at comments on issue ##{issue.number}"
         if issue.last_comment_was_by(me)
            issue.close
         else
            issue.comment_on_issue()
         end
      end
   end
end

Nagnagnag.new.nagnagnag
