# Copy this file to additional_environment.rb and add any statements
# that need to be passed to the Rails::Initializer.  `config` is
# available in this context.
#
# Example:
#
#   config.log_level = :debug
#   ...
#

config.log_level = :debug

config.gem 'dalli'
config.action_controller.perform_caching  = true
config.cache_classes = true
config.cache_store = :dalli_store, "{{MEMCACHE_HOST}}:{{MEMCACHE_PORT}}"
