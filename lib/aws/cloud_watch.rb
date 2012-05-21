require 'aws/core'
require 'aws/cloud_watch/config'

module AWS
  class CloudWatch
    AWS::register_autoloads(self, 'aws/cloud_watch') do
      autoload :Client, 'client'
      autoload :Errors, 'errors'
      autoload :Metric, 'metric'
      autoload :MetricBase, 'metric_base'
      autoload :MetricCollection, 'metric_collection'
      autoload :Request, 'request'
    end

    include Core::ServiceInterface
  end
end
