require 'aws/core/inflection'

module AWS
  class CloudWatch
    
    # @private
    class MetricBase
      include Core::Model
      
      def initialize options
        super
        set_attributes options
      end
      
      def set_attributes attrs
        attrs.keys.each do |k|
          key = k
          key = :name if key == :metric_name
          send("#{key}=", attrs[k]) unless key == :config
        end
      end
      
      attr_accessor :name, :namespace
      attr_reader :dimensions
      
      def dimensions= value
        if value.kind_of? Array
          hash = {}
          value.each do |entry|
            hash[to_sym(entry[:name])] = entry[:value]
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
          @dimensions ||= {}
          @dimensions[$1.to_sym] = args[0]
        else
          super
        end
      end
      
      def options
        opts = dimensions ? {:dimensions => 
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
