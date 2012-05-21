require 'aws/core/inflection'
require 'time'

module AWS
  class CloudWatch
    class Metric < MetricBase
      
      attr_accessor :unit

      def options
        super.merge(unit ? {:unit => unit} : {})
      end
      
      def attr_names
        super + [:unit]
      end
      
      def get statistics, period, range = Time.now, opts = {}
        statistics = [statistics] unless statistics.kind_of? Array
        unless range.kind_of? Range
          range = (range - period)..range
          single_point = true
        else
          single_point = false
        end
        single_point &&= statistics.length == 1
        
        options = self.options.merge({
          :end_time => range.end.getutc.iso8601,
          :start_time => range.begin.getutc.iso8601,
          :period => period.to_i,
          :statistics => statistics.map { |s| camel_case(s) } })
        options[:unit] = camel_case(opts[:unit]) if opts[:unit]
        
        data = client.get_metric_statistics(options).datapoints
        
        if single_point
          data[0][statistics[0]]
        else
          data
        end
      end
      
      def method_missing name, *args
        if [:average, :sum, :sample_count, :maximum, :minimum].include?(name)
          data = get name, *args
          if data.kind_of? Array
            data.each do |point|
              point[:value] = point[name]
            end
          end
          data
        else
          super
        end
      end
      
    end
  end
end
