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
