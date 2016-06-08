Gem::Specification.new do |s|
  s.name = 'sparkle-pack-shell-helpers'
  s.version = '0.1.0'
  s.licenses = ['MIT']
  s.summary = 'SparklePack with various shell helpers to be used in UserData'
  s.authors = ['Timur Batyrshin']
  s.email = 'erthad@gmail.com'
  s.files = Dir[ 'lib/sparkleformation/registry/*' ] + %w(sparkle-pack-shell-helpers.gemspec lib/sparkle-pack-shell-helpers.rb)
end
