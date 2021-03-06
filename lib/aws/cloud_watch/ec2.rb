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

require 'aws/cloud_watch'
require 'aws/ec2'

module AWS
  class CloudWatch
    module EC2

      def metrics
        @metrics ||= MetricCollection.new :namespace => 'AWS/EC2', :instance_id => id, :config => config
      end
      
      def cpu_utilization *args
          metric = metrics['CPUUtilization']
          if args.length == 0
            metric
          else
            metric.average *args
          end
      end
      
      def method_missing name, *args
        if [:disk_read_ops, :disk_write_ops, :network_out, :disk_read_bytes, :network_in, :disk_write_bytes].include?(name)
          metric = metrics[name]
          if args.length == 0
            metric
          else
            metric.sum *args
          end
        else
          super
        end
      end

    end
  end
end

require 'aws/ec2/resource'
require 'aws/ec2/tagged_item'
require 'aws/ec2/instance'

AWS::EC2::Instance.class_eval do
  include AWS::CloudWatch::EC2
end
