class Issue
   def initialize(repo, issue)
      @repo = repo
      @issue = issue
   end

   def last_comment_was_by(github_user)
      comment = last_comment
      comment && comment.user.login == github_user
   end

   def is_old
      @issue.updated_at < (Time.now - 30 * 24 * 60 * 60)
   end

   def number
      @issue && @issue.number
   end

   def self.old_issues(repo)
      issues = Github.api.issues(repo, {
         # all = don't limit to issues assigned to me
         # :filter     => :all,
         :state      => :open,
         :sort       => :updated,
         :direction  => :asc,
         :asignee    => "*"
      })

      batch = issues
      all = []
      while true
         batch.each do |issue_data|
            issue = Issue.new(repo, issue_data)
            if issue.is_old
               if !issue_data[:pull_request]
                  all << issue
               end
            else
               return all
            end
         end
         if batch.length != 0
            batch = Octokit.last_response.rels[:next].get.data
         end
      end
   end

   def last_comment
      comments = Nagnagnag.Github.api.issue_comments(@repo, @issue.number, {
         :sort => :created,
         :direction => :desc
      })
      comments[0] && Comment.new(comments[0])
   end

   def close
   end

   def comment_on_issue
   end
end
