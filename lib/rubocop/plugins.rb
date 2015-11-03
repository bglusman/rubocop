# encoding: utf-8
# This module adds support for loading modules defined in other gems
# that follow the specified naming conventions
module RuboCop
  @extensions = []
  singleton_class.send(:attr_reader, :extensions)
  def self.init_plugins(options) # :nodoc:
    extensions.each do |name|
      msg = "cop_#{name}_init"
      send(msg, options) if self.respond_to? msg
    end
  end

  def self.load_plugins # :nodoc:
    return unless extensions.empty?

    seen = {}

    require 'rubygems' unless defined? Gem
    method = if Gem.respond_to?(:find_latest_files)
               :find_latest_files
             else
               :find_files
             end

    Gem.public_send(method, '*_cop.rb').each do |plugin_path|
      name = File.basename(plugin_path, '_cop.rb')

      next if seen[name]
      seen[name] = true

      require plugin_path
      extensions << name
    end
  end
end
