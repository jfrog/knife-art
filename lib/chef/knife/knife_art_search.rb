
require 'chef/knife'
require 'chef/knife/cookbook_site_search'

class Chef
  class Knife
    class ArtifactorySearch < Knife::SupermarketSearch

      dependency_loaders.concat(superclass.dependency_loaders)
      options.merge!(superclass.options)

      banner "knife artifactory search QUERY (options)"
      category "artifactory"
    end
  end
end
