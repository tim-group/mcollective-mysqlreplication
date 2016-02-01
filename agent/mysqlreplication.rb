
module MCollective
  module Agent
    class Mysqlreplication < RPC::Agent
      action 'show_slave_status' do
        begin
          reply = do_show_slave_status
        end
      end

      def do_show_slave_status
        do_mysql('show slaves status \G')
      end

      def do_mysql(query)
        {
            :successful => true,
            :contents => ''
        }
      end
    end
  end
end
