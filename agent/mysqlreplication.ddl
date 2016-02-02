metadata :name        => "MySQL",
         :description => "Agent To retrieve mysql information from mysql servers",
         :author      => "Infrastructure Team",
         :license     => "MIT",
         :version     => "1.0",
         :url         => "http://www.timgroup.com",
         :timeout     => 120

action "show_slave_status", :description => "Get and print the show slave status on this mysql server" do

  output :contents,
      :description => "Verbatim contents returned from mysql",
      :display_as  => "Contents"

end

