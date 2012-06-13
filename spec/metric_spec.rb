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
    @metric.should_receive(:client).any_number_of_times.and_return(@client = double)
    @begin = Time.utc(2000, 1, 2, 2, 2, 2)
    @begin_iso = "2000-01-02T02:02:02Z"
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

  it 'returns nil when no datapoinst are returned' do
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => "2000-02-02T01:02:03Z",
      :end_time => @end_iso,
      :period => 60*60, # one hour
      :statistics => ["Sum"]
    ).and_return(double :datapoints => [])
    @metric.get(:sum, 60 * 60, @end).should be_nil
  end
  
  it 'returns stats sorted by timestamp' do
    datapoints = [
      {:timestamp => Time.utc(2001, 4, 2, 5, 2, 0)},
      {:timestamp => Time.utc(2011, 3, 1, 12, 4, 32)},
      {:timestamp => Time.utc(2000, 1, 5, 2, 3, 0)}
    ]
    sorted = [
      {:timestamp => Time.utc(2000, 1, 5, 2, 3, 0)},
      {:timestamp => Time.utc(2001, 4, 2, 5, 2, 0)},
      {:timestamp => Time.utc(2011, 3, 1, 12, 4, 32)}
    ]
    
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => @begin_iso,
      :end_time => @end_iso,
      :period => 4600,
      :statistics => ["Sum"]
    ).and_return(double :datapoints => datapoints)
    @metric.get(:sum, 4600, @begin..@end).should == sorted
  end
  
  it 'fetches many batches if number of datapoints is too large' do
    _begin = Time.utc(2012, 01, 01, 0, 0, 0)
    _end = Time.utc(2012, 01, 03, 0, 0, 0)
    
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => "2012-01-01T00:00:00Z",
      :end_time => "2012-01-02T00:00:00Z",
      :period => 60,
      :statistics => ["Sum"]
    ).and_return(double :datapoints => [1, 2, 3])
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => "2012-01-02T00:00:00Z",
      :end_time => "2012-01-03T00:00:00Z",
      :period => 60,
      :statistics => ["Sum"]
    ).and_return(double :datapoints => [4, 5, 6])
    @metric.get(:sum, 60, _begin.._end).should == [1, 2, 3, 4, 5, 6]
  end
  
  it 'handles minute differences in begin and end times gracefully' do
    _begin = Time.utc(2012, 6, 8, 17, 36, 58, 901063)
    _end = Time.utc(2012, 6, 13, 17, 36, 58, 901588)
    
    @client.should_receive(:get_metric_statistics).with(\
      :start_time => "2012-06-08T17:36:58Z",
      :end_time => "2012-06-13T17:36:58Z",
      :period => 300,
      :statistics => ["Sum"]
    ).and_return(double :datapoints => [1, 2, 3])
    @client.should_not_receive(:get_metric_statistics).with(\
      :start_time => "2012-06-13T17:36:58Z",
      :end_time => "2012-06-13T17:36:58Z",
      :period => 300,
      :statistics => ["Sum"]
    )
    @metric.get(:sum, 300, _begin.._end).should == [1, 2, 3]
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
