
module Puppet::Parser::Functions
	newfunction(:check_file, :type => :rvalue) do |args|
    if File.read(args[0]) =~ /args[1]/ then
      return 0
    else
      return 1
    end
	end
end

