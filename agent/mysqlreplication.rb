
module MCollective
  module Agent
    class Mysqlreplication < RPC::Agent
      require 'open4'

      action 'show_slave_status' do
        begin
          reply = do_show_slave_status
        end
      end

      def do_show_slave_status
          query_mysql('show slave status \G')
      end

      def query_mysql(query)
        pid, _stdin, stdout, stderr = Open4.popen4("mysql", "-e", query)
        _ignored, status = Process::waitpid2 pid

        return {
          :successful => status.exitstatus == 0,
          :contents   => convert_mysql_output_to_hash(stdout.read.strip)
        }
      end

      def convert_mysql_output_to_hash(lines)
        results = {}
        output = lines.split("\\n")
        output.each do |line|
          if line.include?(':')
            key, value = line.split(':')
            results[key.strip.to_sym] = value.strip
          end
        end
        results
      end
    end
  end
end
