
module MCollective
  module Agent
    class Mysqlreplication < RPC::Agent
      require 'open4'

      action 'show_slave_status' do
        query_mysql('show slave status \G')
      end

      action 'show_master_status' do
        query_mysql('show master status \G')
      end

      def query_mysql(query)
        pid, _stdin, stdout, stderr = Open4.popen4('mysql', '-e', '--defaults-file=/root/.my.cnf', query)
        _ignored, status = ::Process.waitpid2(pid)

        reply.statuscode = status.exitstatus
        reply.data[:contents] = convert_mysql_output_to_hash(stdout.read.strip)
        reply.fail!(stderr.read.strip, 1) unless status.exitstatus == 0
      end

      def convert_mysql_output_to_hash(lines)
        results = {}
        output = lines.split("\n")
        output.each do |line|
          next unless line.include?(':')
          key, value = line.split(':')
          value.strip! unless value.nil?
          results[key.strip.downcase.to_sym] = value
        end
        results
      end
    end
  end
end
