require 'aws/cloud_watch/metric_collection'

describe AWS::CloudWatch::MetricCollection, '#each' do
  it 'paginates through a token' do
    mc = AWS::CloudWatch::MetricCollection.new({})
    client = double("client")
    mc.should_receive(:client).any_number_of_times.and_return(client)

    names = [:one, :two, :three, :four]
    first_page = names[0..1].map {|n| {:name => n}}
    second_page = names[2..3].map {|n| {:name => n}}
    
    client.should_receive(:list_metrics).and_return(stub :metrics => first_page, :data => {:next_token => :a_token})
    client.should_receive(:list_metrics) do |options|
      options[:next_token].should == :a_token
      stub :metrics => second_page, :data => {}
    end
    
    mc.each do |metric|
      metric.name.should == names.shift
    end
  end
end

describe AWS::CloudWatch::MetricCollection, '#[]' do
  it 'makes a metric with the given name' do
    mc = AWS::CloudWatch::MetricCollection.new :namespace => :foo
    metric = mc[:some_name]
    metric.name.should == 'SomeName'
    metric.namespace.should == :foo
  end
end
