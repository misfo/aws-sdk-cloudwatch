require 'aws/cloud_watch/ec2'

describe AWS::EC2::Instance, '#metrics' do
  it 'returns the collection of metrics filtered by the instance' do
    inst = AWS::EC2::Instance.new :test_id
    ms = inst.metrics
    ms.kind_of? AWS::CloudWatch::MetricCollection.should be_true
    ms.namespace.should == 'AWS/EC2'
    ms.dimensions[:instance_id].should == :test_id
  end
  
  it 'always returns the same instance of the collection' do
    inst = AWS::EC2::Instance.new :test_id
    ms = inst.metrics
    inst.metrics.should === ms
  end
end

describe AWS::EC2::Instance, '#cpu_utilization' do
  before :each do
    @inst = AWS::EC2::Instance.new :some_id
  end

  it 'uses the proper metrics' do
    @inst.cpu_utilization.name.should == 'CPUUtilization'
  end
  
  it 'aggregates by average by default' do
    @inst.should_receive(:metrics).and_return(double :[] => (metric = double))
    metric.should_receive(:average).with(:some, :args).and_return(result = double)
    
    @inst.cpu_utilization(:some, :args).should == result
  end
end

describe AWS::EC2::Instance, ' synthetic metric methods' do
  before :each do
    @inst = AWS::EC2::Instance.new :some_id
    @ms = @inst.metrics
  end
  
  it 'retrieves the proper metric and aggregates by sum' do
    [:disk_read_ops, :disk_write_ops, :network_out, :disk_read_bytes, :network_in, :disk_write_bytes].each do |name|
      @inst.send(name).name == name
    end
  end
  
  it 'aggregates the metric with sum' do
    [:disk_read_ops, :disk_write_ops, :network_out, :disk_read_bytes, :network_in, :disk_write_bytes].each do |name|
      @ms.should_receive(:[]).with(name).and_return(metric = double)
      metric.should_receive(:sum).with(:some, :args).and_return(result = double)
      
      @inst.send(name, :some, :args).should == result
    end
  end
end
