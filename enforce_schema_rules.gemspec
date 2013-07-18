Gem::Specification.new do |s|
  s.name = 'enforce_schema_rules'
  s.version = '0.0.17'
  s.authors = ['Josh Starcher', 'David Easley', 'Michael Schuerig', 'Eric Anderson']
  s.email = ['josh.starcher@gmail.com', nil, nil, 'eric@saveyourcall.com']
  s.add_dependency 'activerecord'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'test-unit'
  s.files = Dir['lib/*']
  s.extra_rdoc_files << 'README.rdoc'
  s.rdoc_options << '--main' << 'README.rdoc'
  s.summary = 'An ActiveRecord plugin to automatically enforce database contraints'
  s.description = <<-DESCRIPTION
    A macro-style method that will automatically read the database
    contraints (null requirements, string length, etc) and enforce those
    at the model level to keep validation more DRY. Provides many
    options to customize how automatic it is and what columns it affects.
  DESCRIPTION
end
