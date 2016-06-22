Gem::Specification.new do |s|
  s.name = 'sparkle-pack-shell-helpers'
  s.version = '0.5.0'
  s.licenses = ['MIT']
  s.summary = 'SparklePack with various shell helpers to be used in UserData'
  s.description = 'Shell helpers to be used in UserData templates for easier generation of shell scripts'
  s.authors = ['Timur Batyrshin']
  s.email = 'erthad@gmail.com'
  s.homepage = 'https://github.com/timurb/sparkle-pack-shell-helpers'
  s.files = Dir[ 'lib/sparkleformation/registry/*' ] + %w(sparkle-pack-shell-helpers.gemspec lib/sparkle-pack-shell-helpers.rb)
end
