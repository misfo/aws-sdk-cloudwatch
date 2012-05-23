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

require 'aws/cloud_watch/client'

describe AWS::CloudWatch::Client, '.api_config' do
  it 'loads api config from proper directory' do
    expected_dir = Pathname.new(File.dirname(__FILE__)).parent
    expected_file = expected_dir.to_s + '/lib/aws/api_config/CloudWatch-2010-08-01.yml'
    
    File.should_receive(:read).with(expected_file).and_return(file = double)
    YAML.should_receive(:load).with(file).and_return(api = double)
    
    AWS::CloudWatch::Client.api_config.should == api
  end
end
