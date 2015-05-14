class Issue
   def initialize(repo, issue)
      @repo = repo
      @issue = issue
   end

   def last_commen_was_by(github_user)
      comment = last_comment
      comment && comment.user.login == github_user
   end

   def by(github_user)
      comment && comment.user.login == github_user
   end

   def self.old_issues
   end

   def last_comment
      comment = Nagnagnag.github.issue_comments(@repo, @issue.number, {
         :sort => :created,
         :direction => :desc
      })
      comment[0] && Comment.new(comment[0])
   end

   def comment_on_issue (issue)
   end
end
