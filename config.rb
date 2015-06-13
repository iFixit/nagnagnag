class Configuration
   attr_accessor :repo,
                 :no_activity_days,
                 :exempt_label

   def initialize
      self.no_activity_days = 30
      Log.debug(self.inspect)
   end

   def no_activity_seconds
      no_activity_days * 86400
   end

   ##
   # Factory method that parses options from the commandline
   ##
   def self.from_commandline
      config = self.new

      options_parser = OptionParser.new do |opts|
         opts.banner = "Usage: nagnagnag --repo=user/repo"

         opts.on("-r", "--repo REPO", "github username/repository") do |v|
            config.repo = v.strip
            Log.debug "Operating on repo #{config.repo}"
         end

         opts.on("--no-activity-days=DAYS", OptionParser::DecimalInteger,
                       "Number of days to wait after the last activity",
                       "on an issue before commenting or closing.") do |v|
            config.no_activity_days = v
            Log.debug "Setting no-activity-days to #{config.no_activity_days}"
         end


         opts.on("--exempt-label=LABEL", String,
                       "Name of issue label that will prevent issues",
                       "from being examined or modified by this bot.") do |v|
            config.exempt_label = v
            Log.debug "Exempting issues with label #{config.exempt_label}"
         end

         opts.on_tail("-h", "--help", "Show this message") do
            puts opts.help
            exit 1
         end
      end

      options_parser.parse!

      if config.repo.nil?
         puts options_parser.help
         exit 2
      end
      config
   end
end
