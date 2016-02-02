
describe MCollective::Agent::Mysqlreplication, :mcollective => true do

  before(:each) do
    agent_file = File.join([File.dirname(__FILE__)], '../agent/mysqlreplication.rb')
    @agent = MCollective::Test::LocalAgentTest.new('mysqlreplication', :agent_file => agent_file).plugin
  end

  describe 'show_slave_status' do
    it 'should succeeds and returns correct information' do
      mock_popen4_with(
        {
          :expected_command => ['mysql', '-e', 'show slave status \\G'],
          :stdout => load_fixture('zero_seconds_behind_production-timdb-002'),
        }
      )
      mock_process_with(:exitstatus => 0)

      result = @agent.call(:show_slave_status)

      expect(result[:statuscode]).to eql(0)
      expect(result[:statusmsg]).to eql('OK')
      data = result[:data]
      expect(data[:contents]).to be_a(Hash)
      expect(data[:contents][:Master_Host]).to eql('production-timdb-002.pg.net.local')
      expect(data[:contents][:Seconds_Behind_Master]).to eql("0")
    end

    it 'should return unsuccessful when mysql returns with error' do
      mock_process_with(:exitstatus => 1)
      result = @agent.call(:show_slave_status)
      expect(result[:statuscode]).to eql(1)
    end
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
    status.expects(:exitstatus).at_most(2).returns(options[:exitstatus])
    if options.key?(:pid)
      Process.expects(:waitpid2).at_least_once.with(options[:pid]).returns([options[:pid], status])
    else
      Process.expects(:waitpid2).at_least_once.returns([nil, status])
    end
  end
end
