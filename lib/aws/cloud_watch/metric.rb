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
      
      MAX_RECORDS = 1440
      
      def get statistics, period, range = Time.now, opts = {}
        statistics = [statistics] unless statistics.kind_of? Array
        unless range.kind_of? Range
          range = (range - period)..range
          single_point = true
        else
          single_point = false
        end
        single_point &&= statistics.length == 1
        
        def get_batch statistics, period, range, opts
          options = self.options.merge({
            :end_time => range.end.getutc.iso8601,
            :start_time => range.begin.getutc.iso8601,
            :period => period.to_i,
            :statistics => statistics.map { |s| camel_case(s) } })
          options[:unit] = camel_case(opts[:unit]) if opts[:unit]
          
          data = client.get_metric_statistics(options).datapoints
        end
        
        if single_point
          data = get_batch statistics, period, range, opts
          
          if data.length == 0
            return nil
          else
            return data[0][statistics[0]]
          end
        end

        max_period = MAX_RECORDS * period / statistics.length
        
        ranges = [range]
        while (ranges[-1].end - ranges[-1].begin) > max_period
          range = ranges.pop
          pivot = range.begin + max_period
          ranges.push range.begin..pivot
          ranges.push pivot..range.end
        end
        
        ranges.map{|range| get_batch statistics, period, range, opts}.flatten.sort{|a, b| a[:timestamp] <=> b[:timestamp]}
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
