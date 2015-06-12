class Comment
   def initialize(comment)
      @comment = comment
   end

   def by(github_user)
      @comment.user.login == github_user
   end

   def user
      @comment.user
   end

   def body_contains(str)
      @comment.body && @comment.body.include?(str)
   end
end
