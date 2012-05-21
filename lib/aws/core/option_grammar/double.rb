require 'aws/core/inflection'
require 'aws/core/option_grammar'
require 'aws/core/meta_utils'

module AWS
  module Core
    class OptionGrammar
      module Descriptors
        
        # @private
        module Double
  
          extend NoArgs
  
          def validate(value, context = nil)
            raise format_error("float value", context) unless
              value.respond_to? :to_f
          end
  
          def encode_value(value)
            value.to_s
          end
  
        end
        
      end
    end
  end
end