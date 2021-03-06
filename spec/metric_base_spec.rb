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

require 'aws/cloud_watch/metric_base'

describe AWS::CloudWatch::MetricBase do
  it 'puts unknown keys in dimensions when initializing' do
    mb = AWS::CloudWatch::MetricBase.new :name => :foo,
        'Something' => :bar, :other => :baz
    mb.name.should == :foo
    mb.dimensions[:other].should == :baz
    mb.dimensions['Something'].should == :bar
  end
end

describe AWS::CloudWatch::MetricBase, '#dimensions=' do
  it 'transforms argument into direct hash form' do
    mb = AWS::CloudWatch::MetricBase.new({})
    mb.dimensions = [{:name => 'Test', :value => 'dimension'}, 
                     {:name => :another, :value => :dimension}]
    mb.dimensions.should == {'Test' => 'dimension',
                             :another => :dimension}
  end
end

describe AWS::CloudWatch::MetricBase, '#options' do
  it 'folds all parameters into a single hash ready for sending to AWS' do
    mb = AWS::CloudWatch::MetricBase.new :name => :foo,
        'Something' => :bar, :other => :baz
    options = mb.options
    options.keys.length.should == 2
    options[:metric_name].should ==  :foo
    dims = options[:dimensions]
    dims.length.should == 2
    [ { :name => 'Something', :value => :bar }, { :name => 'Other', :value => :baz } ].each do |dim|
      dims.include?(dim).should be_true
    end
  end
end
