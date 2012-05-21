require 'aws/cloud_watch/metric'

describe AWS::CloudWatch::Metric, '#options' do
  it 'also takes the unit' do
    m = AWS::CloudWatch::Metric.new :unit => 'barn'
    m.options[:unit].should == 'barn'
  end
end

describe AWS::CloudWatch::Metric, '#get' do
  before(:each) do
    @metric = AWS::CloudWatch::Metric.new({})
    @metric.should_receive(:client).and_return(@client = double)
    @begin = Time.utc(2000, 2, 2, 2, 2, 2)
    @begin_iso = "2000-02-02T02:02:02Z"
    @end = Time.utc(2000, 2, 2, 2, 2, 3)
    @end_iso = "2000-02-02T02:02:03Z"
  end
  
  it 'can collect a single statistic' do
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => @begin_iso,
      :end_time => @end_iso,
      :period => 4600,
      :statistics => ["Sum"]
    ).and_return(double :datapoints => [])
    @metric.get(:sum, 4600, @begin..@end)
  end

  it 'collects one period worth of data if no range is given' do
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => "2000-02-02T01:02:03Z",
      :end_time => @end_iso,
      :period => 60*60, # one hour
      :statistics => ["Sum"]
    ).and_return(double :datapoints => [{:sum => :result}])
    @metric.get(:sum, 60 * 60, @end).should == :result
  end
end

describe AWS::CloudWatch::Metric, " synthetic methods" do
  before(:each) do
    @metric = AWS::CloudWatch::Metric.new({})
    @metric.stub(:client => (@client = double))
    @begin = Time.utc(2000, 2, 2, 2, 2, 2)
    @begin_iso = "2000-02-02T02:02:02Z"
    @end = Time.utc(2000, 2, 2, 2, 2, 3)
    @end_iso = "2000-02-02T02:02:03Z"
  end
  
  it "fetches proper statistic and substitutes :value field" do
    stats = {:average => 'Average',
             :sum => 'Sum',
             :sample_count => 'SampleCount',
             :maximum => 'Maximum',
             :minimum => 'Minimum'
            }
            
    stats.keys.each do |name|
      @client.should_receive(:get_metric_statistics).with(\
        :start_time => @begin_iso,
        :end_time => @end_iso,
        :period => 60*60, # one hour
        :statistics => [stats[name]]
      ).and_return(double :datapoints => [{name => :result}])
      @metric.send(name, 60 * 60, (@begin..@end))[0][:value].should == :result
    end
  end
end
