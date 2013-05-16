require 'rubygems'
require 'pry'
require 'spree/i18n_utils'

module SpreeI18n
  class Sync
    attr_reader :default_entries

    def run
      files.each do |filename|

        basename = File.basename(filename, '.yml')
        comments, entries = Spree::I18nUtils.read_file(filename, basename)

        # Initializing hash variable as en fallback if it does not exist
        default_entries.each { |k,v| entries[k] ||= "#{default_entries[k]}" }

        # Remove if not defined in en locale
        entries.delete_if { |k,v| !default_entries[k] } 

        Spree::I18nUtils.write_file(filename, basename, comments, entries)
      end
    end

    def files
      Dir["#{locales_dir}/ca.yml"]
    end

    def default_entries
      return @default_entries if @default_entries
      comments, entries = Spree::I18nUtils.read_file(default_locale_file, "en")
      @default_entries = entries
    end

    def default_locale_file
      File.join File.dirname(__FILE__), "../../default/spree_core.yml"
    end

    def locales_dir
      File.join File.dirname(__FILE__), "../../config/locales"
    end

    def env_locale
      ENV['LOCALE'].presence
    end
  end

  describe Sync do
    it { subject.run }
  end
end
