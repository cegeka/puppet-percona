# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_database) do
  @doc = "Manage databases."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the database."
  end

end
