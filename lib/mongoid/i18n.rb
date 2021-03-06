require 'mongoid/i18n/localized_field'
require 'mongoid/i18n/localized_criteria'

module Mongoid
  module I18n
    extend ActiveSupport::Concern

    module ClassMethods
      def localized_field(name, options = {})
        field name, options.merge(:type => LocalizedField)
      end

      def criteria
        scope = scope_stack.last rescue nil
        scope || I18n::LocalizedCriteria.new(self)
      end

      protected
      def create_accessors(name, meth, options = {})
        if options[:type] == LocalizedField
          define_method(meth) { read_attribute(name)[::I18n.locale.to_s] rescue '' }
          define_method("#{meth}=") do |value|
            write_attribute(name, (@attributes[name] || {}).merge(::I18n.locale.to_s => value))
          end
          define_method("#{meth}_translations") { read_attribute(name) }
          define_method("#{meth}_translations=") { |value| write_attribute(name, value) }
        else
          super
        end
      end
    end
  end
end