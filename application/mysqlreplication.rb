module Validation
  Command = Struct.new(:show_slave_status, :show_master_status)

  def self.parse(args)
    if %w(show_slave_status show_master_status).include?(args[0])
      Command.new(args[0])
    else
      fail "Invalid command: '#{args.join(' ')}'"
    end
  end
end

module MCollective
  module Application
    Class Mysqlreplication < MCollective::Application
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

    def print_config(host, configStr, mtimeStr)
      printf("%40s: mtime: %s\n", host, mtimeStr)
      configStr.split("\n").each.with_index do |line, lineNum|
        printf("%40s:%3s:   %s\n", host, lineNum, line)
      end
      puts
    end

    def print_error_response(host, reply)
      printf('%40s: %s', host, reply)
    end

    def log_unsuccessful_requests(response)
      print_error_response(response[:sender], response[:statusmsg]) unless response[:statuscode] == 0
    end

    def main
      mc = rpcclient('mysqlreplication')
      mc.fact_filter mysql_exists, true
      mc.send(configuration[:command]).each do |response|
        if response[:statuscode] == 0
          print_config(response[:sender], response[:data][:contents])
        else
          print_error_response(response[:sender], response[:statusmsg])
        end
      end
      mc.disconnect
      printrpcstats
    end
  end
end
