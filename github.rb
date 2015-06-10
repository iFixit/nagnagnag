require 'octokit'
require 'shellwords'

module Github
   ##
   # Get a git config property
   ##
   def self.config(property)
      value = `git config #{property.to_s.shellescape}`.strip
      Log.debug "Reading git config #{property.to_s}: #{value}"
      return value
   end

   ##
   # Get an instance of the Octokit API class
   ##
   def self.api()
      @client ||= OctokitWrapper.new(self::get_authentication())
   end

   ##
   # Return a Hash with an :access_token or die trying.
   def self.get_authentication()
      token    = self::config("github.token")
      if !token.empty?
         return {:access_token => token}
      else
         abort "
This script needs authorized access to the API.
Visit https://github.com/settings/tokens,
generate a token and store it with:
git config github.token 'thetoken'"
      end
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
      Log.debug "Creating new OctokitWrapper"
      @client = Octokit::Client.new(*args)
   end

   def method_missing(meth,*args)
      begin
         return @client.send(meth,*args)
      rescue Octokit::Error => e
         abort("=" * 80 + "\nGithub API Error\n" + e.to_s)
      end
   end
end
