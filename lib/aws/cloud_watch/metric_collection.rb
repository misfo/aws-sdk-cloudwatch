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

module AWS
  class CloudWatch
    class MetricCollection < MetricBase
      
      include Enumerable
      
      def each &block

        next_token = nil

        begin
          
          list_options = options.merge(next_token ? { :next_token => next_token } : {})
          response = client.list_metrics(list_options)

          response.metrics.each do |t|
            metric = Metric.new(t.merge :config => config)
            yield(metric)
          end

        end while(next_token = response.data[:next_token])
        nil

      end
      
      def get_by_name name
        Metric.new(options.merge(:name => camel_case(name)))
      end
      
      alias_method :[], :get_by_name
      
    end
  end
end
