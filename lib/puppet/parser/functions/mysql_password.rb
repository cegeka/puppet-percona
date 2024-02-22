# hash a string as mysql's "PASSWORD()" function would do it
require 'digest/sha2'

module Puppet::Parser::Functions
	newfunction(:mysql_password, :type => :rvalue) do |args|
		'*' + Digest::SHA2.hexdigest(Digest::SHA2.digest(args[0])).upcase
	end
end

