require 'octokit'

Octokit.auto_traversal = true
module Github
   ##
   # Get a global git config property
   ##
   def self.config(property)
      `git config --global #{property.to_s.shellescape}`.strip
   end

   ##
   # Get a local (to the repo) git config property
   ##
   def self.local_config(property)
      `git config #{property.to_s.shellescape}`.strip
   end

   ##
   # Get an instance of the Octokit API class
   #
   # Authorization info is the structure from here:
   # http://developer.github.com/v3/oauth/#create-a-new-authorization
   #
   # something like this:
   # {
   #     :scopes => ['repo'],
   #     :note => "some cool project",
   #     :note_url => "http://homepage-for-project.com"
   # }
   ##
   def self.api(authorization_info = {})
      # Let Octokit handle pagination automagically for us.
      Octokit.auto_traversal = true
      # Defaults
      authorization_info = {
         :scopes => ['repo'],
         :note => "nagnagnag -- The GH issues bot that nags you and closes issues",
         :note_url => "https://github.com/ifixit/nagnagnag"
      }.merge(authorization_info)
      OctokitWrapper.new(self::get_authentication(authorization_info))
   end

   def self.get_authentication(authorization_info)
      username = self::config("github.user")
      token    = self::config("github.token")
      if !token.empty?
         return {:access_token => token}
      else
         return self::request_authorization(authorization_info)
      end
   end

   ##
   # Returns a hash containing the username and github oauth token
   #
   # Prompts the user for credentials if the token isn't stored in git config
   ##
   def self.request_authorization(authorization_info)
      puts "Authorizing..."

      username ||= Readline.readline("github username: ", true)
      password   = ask("github password: ") { |q| q.echo = false }

      octokit = OctokitWrapper.new(:login => username, :password => password)

      auth = octokit.authorizations.find {|auth|
         note = auth['note']
         note && note.include?(authorization_info[:note])
      }

      auth = auth || octokit.create_authorization(authorization_info)

      success =
         system("git config --global github.user #{username}") &&
         system("git config --global github.token #{auth[:token]}")

      unless success
         die("Couldn't set git config")
      end

      return {:login => username, :oauth_token => auth[:token]}
   end

   ##
   # Returns the github repo identifier in the form that the API likes:
   # "someuser/theirrepo"
   #
   # Requires the "origin" remote to be set to a github url
   ##
   def self.get_github_repo()
      url = self::local_config("remote.origin.url")
      m = /github\.com.(.*?)\/(.*)/.match(url)
      if m
        return [m[1], m[2].sub(/\.git\Z/, "")].join("/")
      else
         raise "remote.origin.url in git config but be a github url"
      end
   end
end

class OctokitWrapper
   def initialize(*args)
      @client = Octokit::Client.new(*args)
   end

   def method_missing(meth,*args)
      begin
         return @client.send(meth,*args)
      rescue Octokit::Error => e
         die("=" * 80 + "\nGithub API Error\n" + e.to_s)
      end
   end
end
