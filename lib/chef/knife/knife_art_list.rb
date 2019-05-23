
require 'chef/knife'
require 'chef/knife/cookbook_site_list'

class Chef
  class Knife
    class ArtifactoryList < Knife::SupermarketList

      dependency_loaders.concat(superclass.dependency_loaders)
      options.merge!(superclass.options)

      banner "knife artifactory list (options)"
      category "artifactory"
    end
  end
end
