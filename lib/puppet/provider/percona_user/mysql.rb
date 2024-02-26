Puppet::Type.type(:percona_user).provide(:mysql) do

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  #optional_commands :mysqladmin => 'mysqladmin'

  def self.instances
    users = mysql([defaults_file, "mysql", '-BNe' "select concat(User, '@',Host) as User from mysql.user"].compact).split("\n")
    users.select{ |user| user =~ /.+@/ }.collect do |name|
      new(:name => name)
    end
  end

  def create
    username = @resource[:name].sub("@", "'@'")
    password = @resource.value(:password_user)
    
    command = "/bin/mysql --defaults-file=/root/.my.cnf mysql -e \"create user '#{username}' identified by '#{password}'\""
  
    success = system("#{command} >/dev/null 2>&1")
    
    if success
      Puppet.notice("User #{username} was successfully created.")
    else
      Puppet.err("Failed to create user #{username} - Check password requirements")
    end
  end


  def destroy
    mysql([defaults_file, "mysql", "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'") ].compact)
  end

  def password_user
    mysql_version = mysql(["-V"])
    percona_version=%r{(Distrib|Ver?) (\d+\.\d+)\.\d+}.match(mysql_version)[2].gsub('.','')
    if percona_version.to_i >= 57
      mysql([defaults_file, "mysql", "-NBe", "select authentication_string from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)].compact).chomp
    else
      mysql([defaults_file, "mysql", "-NBe", "select password from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)].compact).chomp
    end
  end

  
  def password_user=(string)
    username = @resource[:name].sub("@", "'@'")
    password = @resource.value(:password_user)

    command = "/bin/mysql --defaults-file=/root/.my.cnf mysql -e \"alter user '#{username}' identified by '#{password}'\""

    success = system("#{command} >/dev/null 2>&1")

    if success
      Puppet.notice("User #{username} was successfully altered.")
    else
      Puppet.err("Failed to alter user #{username} - Check password requirements")
    end
  end

  def exists?
    not mysql([defaults_file, "mysql", "-NBe", "select '1' from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)].compact).empty?
  end

  def flush
    @property_hash.clear
  end

  # Optional defaults file
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

end
