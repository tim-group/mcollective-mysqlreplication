require 'mcollective'
require 'rspec'
require 'open4'
require 'stringio'


describe MCollective::Agent::Mysqlreplication, :mcollective => true do

  before(:each) do
    agent_file = File.join([File.dirname(__FILE__)], '../agent/mysqlreplication.rb')
    @agent = MCollective::Test::LocalAgentTest.new('mysqlreplication', :agent_file => agent_file).plugin
  end

  def expect_to_run_mock_output(options)
    stdout = StringIO.new(options[:stdout])
    stderr = StringIO.new(options[:stderr])
    stdin = StringIO.new

    status = mock
    status.expects(:exitstatus).returns(options[:exit_code])

    Open4.expects(:popen4).with(*options[:expected_command]).returns([100, stdin, stdout, stderr])
    Process.expects(:waitpid2).with(100).returns([nil, status])
  end

  it 'responds with an error if there is no config file location fact available' do

    # FIXME: Move this to a fixture file
    dummy_output = "*************************** 1. row ***************************\n               Slave_IO_State: Waiting for master to send event\n                  Master_Host: production-timdb-002.pg.net.local\n                  Master_User: replicant\n                  Master_Port: 3306\n                Connect_Retry: 60\n              Master_Log_File: mysqld-bin.007907\n          Read_Master_Log_Pos: 51948862\n               Relay_Log_File: mysqld-relay-bin.022571\n                Relay_Log_Pos: 51949026\n        Relay_Master_Log_File: mysqld-bin.007907\n             Slave_IO_Running: Yes\n            Slave_SQL_Running: Yes\n              Replicate_Do_DB: tradeideasmonitor,percona,tradeideasmonitor\n          Replicate_Ignore_DB: \n           Replicate_Do_Table: \n       Replicate_Ignore_Table: tradeideasmonitor.CACHE\n      Replicate_Wild_Do_Table: \n  Replicate_Wild_Ignore_Table: \n                   Last_Errno: 0\n                   Last_Error: \n                 Skip_Counter: 0\n          Exec_Master_Log_Pos: 51948862\n              Relay_Log_Space: 51949470\n              Until_Condition: None\n               Until_Log_File: \n                Until_Log_Pos: 0\n           Master_SSL_Allowed: No\n           Master_SSL_CA_File: \n           Master_SSL_CA_Path: \n              Master_SSL_Cert: \n            Master_SSL_Cipher: \n               Master_SSL_Key: \n        Seconds_Behind_Master: 0\nMaster_SSL_Verify_Server_Cert: No\n                Last_IO_Errno: 0\n                Last_IO_Error: \n               Last_SQL_Errno: 0\n               Last_SQL_Error: \n  Replicate_Ignore_Server_Ids: \n             Master_Server_Id: 1002\n                  Master_UUID: 27a8e780-91ed-11e5-8516-525400ffc8a7\n             Master_Info_File: /var/lib/mysql/master.info\n                    SQL_Delay: 0\n          SQL_Remaining_Delay: NULL\n      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it\n           Master_Retry_Count: 86400\n                  Master_Bind: \n      Last_IO_Error_Timestamp: \n     Last_SQL_Error_Timestamp: \n               Master_SSL_Crl: \n           Master_SSL_Crlpath: \n           Retrieved_Gtid_Set: \n            Executed_Gtid_Set: \n                Auto_Position: 0"


    expect_to_run_mock_output (
      {
        :expected_command => ['mysql', '-e', 'show slave status \\G'],
        :stdout => dummy_output,
        :stderr => '',
        :exit_code => 0
      }
    )

    reply = @agent.do_show_slave_status

    expect(reply[:successful]).to be(true)
    expect(reply[:contents]).to be_a(Hash)
    contents = reply[:contents]
    expect(contents[:Master_Host]).to eql('production-timdb-002.pg.net.local')
    expect(contents[:Seconds_Behind_Master]).to eql("0")
  end
end
