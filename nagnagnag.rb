require 'rubygems'
require 'octokit'
require 'optparse'
require './github.rb'
require './models/issue.rb'
require './models/comment.rb'
require './log.rb'
require './config.rb'

class Nagnagnag 
   def initialize
      # Mostly to ensure printing help is the first thing we do
      Nagnagnag.config
      @client = Github.api
      @@instance = self
   end

   def self.config
      @config ||= Configuration.from_commandline
   end

   def github
      @client
   end

   def nagnagnag
      Issue.old_issues(Nagnagnag.config.repo).each do |issue|
         Log.debug "Looking at comments on issue ##{issue.number}"
         if issue.last_comment_was_from_nagnagnag
            if issue.should_close
               issue.close
            end
         elsif issue.should_comment
            issue.comment_on_issue
         end
      end
   end
end

Nagnagnag.new.nagnagnag
