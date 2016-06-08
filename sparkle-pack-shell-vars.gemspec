Gem::Specification.new do |s|
  s.name = 'sparkle-pack-shell-vars'
  s.version = '0.1.0'
  s.licenses = ['MIT']
  s.summary = 'SparklePack for producing shell-style variable assignments'
  s.description = 'SparklePack to detect AWS availability zones for configured region and provide them as an array'
  s.authors = ['Timur Batyrshin']
  s.email = 'erthad@gmail.com'
  s.files = Dir[ 'lib/sparkleformation/registry/*' ] + %w(sparkle-pack-shell-vars.gemspec lib/sparkle-pack-shell-vars.rb)
end
