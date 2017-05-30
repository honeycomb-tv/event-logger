Gem::Specification.new do |s|
  s.name        = 'event-logger'
  s.version     = '0.0.5'
  s.date        = '2017-05-30'
  s.summary     = 'Event Logger'
  s.description = 'Consistent Event Logging'
  s.authors     = ['Honeycomb']
  s.email       = 'developers@honeycomb.tv'
  s.files       = ['lib/event_logger.rb']
  s.add_runtime_dependency('uuidtools')
end
