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
