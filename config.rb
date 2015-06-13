class Configuration
   attr_accessor :repo,
                 :stale_after_days,
                 :exempt_label,
                 :dry_run

   def initialize
      self.stale_after_days = 30
   end

   def stale_after_seconds
      stale_after_days * 86400
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

         opts.on("--stale-after-days DAYS", OptionParser::DecimalInteger,
                       "Number of days to wait after the last activity",
                       "on an issue before commenting or closing.") do |v|
            config.stale_after_days = v
            Log.debug "Setting stale_after_days to #{config.stale_after_days}"
         end

         opts.on("--dry-run",
                 "Don't actually write anything to github, only read") do |v|
            config.dry_run = v
            Log.debug "Setting dry-run"
         end

         opts.on("--exempt-label LABEL", String,
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
