class Comment
   def initialize(comment)
      @comment = comment
   end

   def by(github_user)
      @comment.user.login == github_user
   end
end
