module Validation
  Command = Struct.new(:command)

  def self.parse(args)
    if %w(show_slave_status show_master_status).include?(args[0])
      Command.new(args[0])
    else
      fail "Invalid command: '#{args.join(' ')}'"
    end
  end
end

module MCollective
  class Application
    class Mysqlreplication < MCollective::Application
      include Validation

      description 'Retrieves config.properties from application servers'
      usage <<-USAGE
      mco mysqlreplication [show_slave_status][show_master_status] [FILTERS]

      show_show_status   - read the show slave status information from mysql.
      show_master_status - read the show master status information from mysql.

      USAGE

      def post_option_parser(configuration)
        validated_command = Validation.parse(ARGV)
        command_as_hash = Hash[validated_command.members.map(&:to_sym).zip(validated_command.to_a)]
        configuration.merge!(command_as_hash)
      end

      def print_response(host, contents)
        if contents.empty?
          printf("%40s: %s\n", host, 'Empty contents returned') if contents.empty?
        else
          contents.each do |key, value|
            printf("%40s: %3s: %s\n", host, key, value)
          end
        end
      end

      def print_error_response(host, reply)
        printf('%40s: %s', host, reply)
      end

      def log_unsuccessful_requests(response)
        print_error_response(response[:sender], response[:statusmsg]) unless response[:statuscode] == 0
      end

      def main
        mc = rpcclient('mysqlreplication')
        mc.fact_filter 'mysql_exists', true
        mc.send(configuration[:command]).each do |response|
          if response[:statuscode] == 0
            sorted_contents = response[:data][:contents].sort_by { | key, value| key }
            print_response(response[:sender], sorted_contents)
          else
            print_error_response(response[:sender], response[:statusmsg])
          end
        end
        mc.disconnect
        printrpcstats
      end
    end
  end
end
