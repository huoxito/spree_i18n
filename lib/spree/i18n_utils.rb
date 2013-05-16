require 'active_support/core_ext'

module Spree
  module I18nUtils

    # Retrieve comments, translation data in hash form
    def read_file(filename, basename)
      (comments, data) = IO.read(filename).split(/#{basename}:\s*\n/)   #Add error checking for failed file read?
      return comments, create_hash(data)
    end
    module_function :read_file

    # Creates hash of translation data
    def create_hash(data)
      words = Hash.new
      return words if !data
      parent = Array.new
      previous_key = 'base'
      data.split("\n").each do |w|
        next if w.strip.blank? || w.strip[0]=='#'
        (key, value) = w.split(':', 2)
        value ||= ''
        shift = (key =~ /\w/)/2 - parent.size                             #Determine level of current key in comparison to parent array
        key = key.sub(/^\s+/,'')
        parent << previous_key if shift > 0                               #If key is child of previous key, add previous key as parent
        (shift*-1).times { parent.pop } if shift < 0                      #If key is not related to previous key, remove parent keys
        previous_key = key                                                #Track key in case next key is child of this key
        words[parent.join(':')+':'+key] = value
      end
      words
    end
    module_function :create_hash

    # Writes to file from translation data hash structure
    def write_file(filename, basename, comments, entries)
      File.open(filename, "w") do |log|
        log.puts(basename + ":\n")


        entries.each do |k, v|

          keys = k.split(':')
          n = keys.size - 1
          value = v.strip

          # Add indentation for children keys
          n.times { keys[n] = '  ' + keys[n] } 

          string = if value.blank?
            "#{keys[n]}:\n"
          else
            "#{keys[n]}: #{v.strip}\n"
          end

          log.puts string
        end
      end
    end
    module_function :write_file
  end
end
