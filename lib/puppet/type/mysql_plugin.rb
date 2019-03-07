# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_plugin) do
  @doc = "Manage plugins."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the plugin."
  end

end
