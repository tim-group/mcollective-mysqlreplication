require 'mcollective'


describe MCollective::Agent::Mysqlreplication, :mcollective => true do
  before(:each) do
    agent_file = File.join([File.dirname(__FILE__)], '../agent/mysqlreplication.rb')
    @agent = MCollective::Test::LocalAgentTest.new('mysqlreplication', :agent_file => agent_file).plugin
  end

  it 'responds with an error if there is no config file location fact available' do
    reply = @agent.do_show_slave_status
    expect(reply[:successful]).to be(true)
  end
end
