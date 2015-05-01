# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
   s.name = 'nagnagnag'
   s.version = '0.0.1'
   s.date = Time.now.strftime('%Y-%m-%d')

   s.authors = ['Daniel Beardsley']
   s.email = ['daniel.beardsley@gmail.com']

   s.add_dependency 'bundler'
   s.add_dependency 'octokit', '~> 3.0'

   s.files = %w( README.md nagnagnag.rb )

   s.executables = ['nagnagnag']

   s.summary = %q{Auto-comment on stale github issues and close them if no-one responds}
   s.homepage = 'https://github.com/iFixit/nagnagnag/'
   s.description = s.summary
end
