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

   def is_old
      @issue.updated_at < (Time.now - Nagnagnag.config.no_activity_seconds)
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
   # Returns array of Issue objects for all issues that haven't been updated
   # in Nagnagnag.config.no_activity_days
   ##
   def self.old_issues(repo)
      Log.info "Loading issues and selecting only the stale ones"
      issues = Github.api.issues(repo, {
         # all = don't limit to issues assigned to me
         # :filter     => :all,
         :state      => :open,
         :sort       => :updated,
         :direction  => :asc,
         :asignee    => "*",
         :per_page   => 100
      })

      batch = issues
      response = Github.api.last_response

      all = []
      while batch.length > 0
         Log.info "Loaded batch of #{batch.length} issues"
         batch.each do |issue_data|
            issue = Issue.new(repo, issue_data)
            if issue.is_old
               continue if issue.is_pull_request
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
         if response.rels[:next]
            Log.info "Loading next page of issues"
            response = response.rels[:next].get
            batch = response.data
         else
            Log.info "Reached the end of the issues"
            break;
         end
      end
      all
   end

   def last_comment
      Log.info "Loading last_comment for issue ##{@issue.number}"
      comments = Github.api.issue_comments(@repo, @issue.number, {
         :sort => :created,
         :direction => :desc,
         :per_page => 1
      })
      comments[0] && Comment.new(comments[0])
   end

   def close
      Log.info "Closing issue ##{@issue.number}"
      if !Nagnagnag.config.dry_run
         Github.api.close_issue(@repo, @issue.number)
      end
   end

   def comment_on_issue
      Log.info "Commenting on issue ##{@issue.number}"
      if !Nagnagnag.config.dry_run
         Github.api.add_comment(@repo, @issue.number, warning_message)
      end
   end

   protected
   def warning_message
      days = Nagnagnag.config.no_activity_days
      str = <<-COMMENT
         **#{intro_text}**
         This issue hasen't seen any activity in #{days} days.
         It will be automatically closed after another #{days} days
         unless #{exempt_label_message} there are further comments.
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
