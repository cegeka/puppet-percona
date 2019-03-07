Puppet::Type.type(:mysql_plugin).provide(:mysql) do
  desc "Manages MySQL plugins."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'

  def self.defaults_file
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      "--defaults-file=#{Facter.value(:root_home)}/.my.cnf"
    else
      nil
    end
  end

  def defaults_file
    self.class.defaults_file
  end

  def self.instances
    mysql([defaults_file, '-NBe', "show plugins"].compact).split("\n").collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql([defaults_file, '-NBe', "INSTALL PLUGIN #{@resource[:name]} SONAME '#{@resource[:name]}.so'"].compact)
  end

  def destroy
    mysql([defaults_file, '-NBe', "UNINSTALL PLUGIN #{@resource[:name]}"].compact)
  end

  def exists?
    begin
      mysql([defaults_file, '-NBe', "show plugins"].compact).match(@resource[:name])
    rescue => e
      debug(e.message)
      return nil
    end
  end

end
