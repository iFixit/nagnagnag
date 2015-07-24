class Issue
   def initialize(repo, issue)
      @repo = repo
      @issue = issue
   end

   def last_comment_was_by(github_user)
      Log.debug "Checking author of last comment on issue ##{@issue.number}"
      comment = last_comment
      Log.debug "Author: #{comment && comment.user.login || '[unknown]'}"
      comment &&
      comment.user.login == github_user &&
      comment.body_contains(intro_text)
   end

   ##
   # Returns true if the last comment was made more than
   # `--stale-after-days` ago
   def should_comment
      last_activity_date < (Time.now - Nagnagnag.config.stale_after_seconds)
   end

   ##
   # Returns true if the last comment was made more than
   # `--close-after-days` ago
   def should_close
      last_activity_date < (Time.now - Nagnagnag.config.close_after_seconds)
   end

   ##
   # Returns true if there has been no activity on the issue whatsoever
   # in the last min(close-after-days, stale-after-days) days.
   def no_recent_activity
      config = Nagnagnag.config
      old_after_seconds = [config.close_after_seconds, config.stale_after_seconds].min
      @issue.updated_at < (Time.now - old_after_seconds)
   end

   ##
   # Returns true if an issue has a numeric label
   def has_score
      @issue.labels.any? do |label|
         val = Integer(label.name) rescue nil
         !!val
      end
   end

   def is_pull_request
      @issue.pull_request
   end

   def is_exempt
      exempt_label = Nagnagnag.config.exempt_label
      exempt_label &&
      @issue.labels.any? { |label| label.name == exempt_label }
   end

   def number
      @issue && @issue.number
   end

   ##
   # Returns array of Issue objects
   ##
   def self.get_issues(repo)
      Log.info "Loading all issues"
      Github.api.issues(repo, {
         # all = don't limit to issues assigned to me
         # :filter     => :all,
         :state      => :open,
         :sort       => :updated,
         :direction  => :asc,
         :assignee   => "*",
         :per_page   => 100
      })
   end

   def self.unscored_issues(issues, repo)
      Log.info "Selecting unscored issues"
      all = []
      Github.each(issues) do |issue_data|
         issue = Issue.new(repo, issue_data)
         next if issue.is_pull_request

         unless issue.has_score
            if issue.is_exempt
               Log.debug "Issue ##{issue.number} is exempt"
            else
               all << issue
               Log.debug "Issue ##{issue.number} does not have a score"
            end
         end
      end
      Log.info "Found #{all.length} unscored issues"
      all
   end

   ##
   # Returns array of Issue objects for all issues that haven't been updated
   # in Nagnagnag.config.stale_after_days
   ##
   def self.old_issues(issues, repo)
      Log.info "Selecting stale issues"
      all = []
      Github.each(issues) do |issue_data|
         issue = Issue.new(repo, issue_data)
         if issue.no_recent_activity
            next if issue.is_pull_request
            if issue.is_exempt
               Log.debug "Issue ##{issue.number} is exempt"
            else
               all << issue
               Log.debug "Issue ##{issue.number} is stale"
            end
         else
            Log.info "Found #{all.length} stale issues"
            return all
         end
      end
      Log.info "Found #{all.length} stale issues"
      all
   end

   def last_activity_date
      (last_comment && last_comment.date) || @issue.created_at
   end

   def last_comment
      @last_comment ||= get_last_comment
   end

   def get_last_comment
      Log.info "Loading last_comment for issue ##{@issue.number}"
      comments = get_all_comments
      comments.last && Comment.new(comments.last)
   end

   def get_all_comments
      comments = Github.api.issue_comments(@repo, @issue.number)

      all = []
      Github.each(comments) do |comment|
         all << comment
      end
      all
   end

   def close
      Log.info "Closing issue ##{@issue.number}"
      if !Nagnagnag.config.dry_run
         Github.api.close_issue(@repo, @issue.number)
      end
   end

   def comment_stale_warning
      Log.info "Commenting stale warning on issue ##{@issue.number}"
      if !Nagnagnag.config.dry_run
         Github.api.add_comment(@repo, @issue.number, warning_message)
      end
   end

   def comment_score_reminder
      Log.info "Commenting score reminder on issue ##{@issue.number}"
      if !Nagnagnag.config.dry_run
         Github.api.add_comment(@repo, @issue.number, score_reminder)
      end
   end

   protected
   def warning_message
      days = Nagnagnag.config.stale_after_days
      close_days = Nagnagnag.config.close_after_days
      str = <<-COMMENT
         **#{intro_text}**
         This issue hasn't seen any activity in #{days} days.
         It will be automatically closed after another #{close_days} days
         unless #{exempt_label_message} there are further comments.
      COMMENT
      str.gsub(/\s+/, ' ')
   end

   protected
   def score_reminder
      str = <<-COMMENT
         **#{intro_text}**
         This issue does not have a difficulty score. Please add a label
         estimating the difficulty of this project.
      COMMENT
      str.gsub(/\s+/, ' ')
   end

   def exempt_label_message
      label = Nagnagnag.config.exempt_label
      return label ? "the `#{label}` label is added or" : ""
   end

   def intro_text
      "From Nagnagnag:"
   end
end
