require 'alephant/preview/template/base'
require 'alephant/preview/template/updater'

module Alephant
  module Preview
    module Template
      def self.path
        "#{Dir.pwd}/components/lib"
      end

      def self.update(template_location)
        Updater.new.update(template_location)
      end
    end
  end
end
