module AWS
  class CloudWatch
    
    # @private
    class Request < Core::Http::Request
      
      include Core::Signature::Version4
      
      def service
        'cloudwatch'
      end
      
    end
    
  end
end
