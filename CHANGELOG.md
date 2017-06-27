# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 1.0.0

No incompatible changes, first major (stable) release.

### Added
- Add `logger` configuration option and `EVENT_LOGGER_LOGGER` environment
  variable to change log output locations
- Add JSON output format for compatibility with the Docker Logentries
  container, set `EVENT_LOGGER_LOGGER=stdout` to enable it
- Add `event-logger` file to match gem name

### Changed
- Replaced uuidtools with SecureRandom UUID generator

### Fixed
- Fix missing homepage, licence data in gemspec
