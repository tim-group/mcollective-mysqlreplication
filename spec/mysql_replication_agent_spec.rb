require 'mcollective'
require 'rspec'
require 'open4'
require 'stringio'

describe MCollective::Agent::Mysqlreplication, :mcollective => true do

  before(:each) do
    agent_file = File.join([File.dirname(__FILE__)], '../agent/mysqlreplication.rb')
    @agent = MCollective::Test::LocalAgentTest.new('mysqlreplication', :agent_file => agent_file).plugin
  end

  it 'do_show_slave_status responds with correct information' do
    mock_popen4_with(
      {
        :expected_command => ['mysql', '-e', 'show slave status \\G'],
        :stdout => load_fixture('zero_seconds_behind_production-timdb-002'),
      }
    )
    mock_process_with(:exitstatus => 0)

    reply = @agent.do_show_slave_status

    expect(reply[:successful]).to be(true)
    expect(reply[:contents]).to be_a(Hash)
    expect(reply[:contents][:Master_Host]).to eql('production-timdb-002.pg.net.local')
    expect(reply[:contents][:Seconds_Behind_Master]).to eql("0")
  end

  def load_fixture(filename)
    path = File.join([File.dirname(__FILE__)], "fixtures/#{filename}")
    File.new(path).read
  end

  # FIXME: Adds no value move to a shared lib
  def mock_popen4_with(options)
    stdout = StringIO.new(options[:stdout] || '')
    stderr = StringIO.new(options[:stderr] || '')
    stdin = StringIO.new
    Open4.expects(:popen4).with(*options[:expected_command]).returns([options[:pid], stdin, stdout, stderr])
  end

  # FIXME: Adds no value move to a shared lib
  def mock_process_with(options)
    status = mock
    status.expects(:exitstatus).returns(options[:exitstatus])
    Process.expects(:waitpid2).with(options[:pid]).returns([options[:pid], status])
  end
end
