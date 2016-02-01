
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
        do_mysql('show slave status \G')
      end

      def convert_mysql_output_to_hash(lines)
        results = {}
        output = lines.split("\n")
        output.shift
        output.each do |line|
          key, value = line.split(':')
          results[key.strip.to_sym] = value.strip
        end
        results
      end


      def do_mysql(query)
        pid, _stdin, stdout, stderr = Open4.popen4("mysql","-e","#{query}")
        _ignored, status = Process::waitpid2 pid
        successful = status.exitstatus == 0 ? true : false
        #pp stdout.read
        results = convert_mysql_output_to_hash(stdout.read.strip)
        response = {
          :successful => successful,
          :contents   => results
        }
        #response[:errorMsg] = stderr.read.strip unless successful
        response
      end

    end
  end
end
