require 'aws/core/option_grammar/double'

module AWS
  class CloudWatch
    
    class Client < Core::Client
      
      API_VERSION = '2010-08-01'
      
      extend Core::Client::QueryXML
      
      CACHEABLE_REQUESTS = Set[
        # TODO
      ]
      
      define_client_method :delete_alarms, 'DeleteAlarms'
      define_client_method :describe_alarm_history, 'DescribeAlarmHistory'
      define_client_method :describe_alarms, 'DescribeAlarms'
      define_client_method :describe_alarms_for_metric, 'DescribeAlarmsForMetric'
      define_client_method :disable_alarm_actions, 'DisableAlarmActions'
      define_client_method :enable_alarm_actions, 'EnableAlarmActions'
      define_client_method :get_metric_statistics, 'GetMetricStatistics'
      define_client_method :list_metrics, 'ListMetrics'
      define_client_method :put_metric_alarm, 'PutMetricAlarm'
      define_client_method :put_metric_data, 'PutMetricData'
      define_client_method :set_alarm_state, 'SetAlarmState'
    
    end
    
  end
end