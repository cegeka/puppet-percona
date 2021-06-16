
module Puppet::Parser::Functions
  newfunction(:check_file, :type => :rvalue) do |args|

    search_file=args[0]
    search_regex=args[1]

    if File.file?(search_file) then
      if File.read(search_file) =~ /#{search_regex}/ then
        return 0
      else
        return 1
      end
    else
      return 2
    end
  end
end
