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
      me = Github::config("github.user")
      all_issues = Issue.get_issues(Nagnagnag.config.repo)

      Issue.old_issues(all_issues, Nagnagnag.config.repo).each do |issue|
         Log.debug "Looking at comments on issue ##{issue.number}"
         if issue.last_comment_was_by(me)
            if issue.should_close
               issue.close
               Log.debug "Should close #{issue.number}"
            end
         elsif issue.should_comment
            issue.comment_stale_warning
            Log.debug "Should comment #{issue.number}"
         end
      end

      Issue.unscored_issues(all_issues, Nagnagnag.config.repo).each do |issue|
         Log.debug "Looking for score on issue ##{issue.number}"
         issue.comment_score_reminder
         Log.debug "Should comment #{issue.number}"
      end

      milestone_issues = Issue.get_issues(Nagnagnag.config.repo, {:milestone => '*'})
      Issue.due_issues(milestone_issues, Nagnagnag.config.repo).each do |issue|
         Log.debug "Looking at milestone due date on issue ##{issue.number}"
         if issue.due_soon && !issue.has_pull
            issue.comment_milestone_reminder
         end
      end
   end
end

Nagnagnag.new.nagnagnag
