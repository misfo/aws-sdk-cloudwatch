# Copyright 2012 Inscitiv
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'aws/core/inflection'

module AWS
  class CloudWatch
    
    # @private
    class MetricBase
      include Core::Model
      
      def initialize options
        super
        @dimensions = {}
        set_attributes options
      end
      
      def set_attributes attrs
        attrs.keys.each do |k|
          key = k
          key = :name if key == :metric_name
          if key.kind_of? Symbol
            send("#{key}=", attrs[k]) unless key == :config
          else
            dimensions[key] = attrs[k]
          end
        end
      end
      
      attr_accessor :name, :namespace
      attr_reader :dimensions
      
      def dimensions= value
        if value.kind_of? Array
          hash = {}
          value.each do |entry|
            hash[entry[:name]] = entry[:value]
          end
          value = hash
        end
        
        @dimensions = value
      end
      
      def attr_names
        [:dimensions, :name, :namespace]
      end
      
      def method_missing name, *args
        if args.length == 1 && name.to_s =~ /^(.*)=/ then
          @dimensions[$1.to_sym] = args[0]
        else
          super
        end
      end
      
      def options
        opts = !dimensions.empty? ? {:dimensions => 
              dimensions.keys.map {|key|
              { :name => camel_case(key),
                :value => dimensions[key] }}
          } : {}

        opts[:metric_name] = name if name
        opts[:namespace] = namespace if namespace
        opts
      end

      def camel_case s
        Core::Inflection.class_name s.to_s
      end

      def to_sym s
        Core::Inflection.ruby_name(s.to_s).to_sym
      end

      def inspect
        attrs = []
        attr_names.each do |attr|
          val = self.send attr
          attrs << "#{attr}:#{val.inspect}" if val
        end
        
        "<#{self::class} #{attrs.join ' '}>"
      end
    end
  end
end
