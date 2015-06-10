require 'logger'

class Log
   def self.instance
      @@logger ||= Logger.new(STDOUT)
   end

   def self.method_missing(method, *args)
      instance.send(method, *args)
   end
end
