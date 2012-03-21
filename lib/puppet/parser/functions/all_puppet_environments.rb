# Extracts the $name of every puppet resource of type Puppet::Environment in
# the catalog. Concatenes them all and returns the resulting string.
module Puppet::Parser::Functions
  newfunction(:all_puppet_environments, :type => :rvalue) do |args|

    envs = []

    catalog.resources.each do |r|
      if r.to_s.match(/^Puppet::Environment\[/) and
         r[:ensure] != "absent"
        envs << r.title
      end
    end

    envs.sort.join(",")

  end
end
