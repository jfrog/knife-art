
require 'chef/knife'
require 'chef/knife/supermarket_show'

class Chef
  class Knife
    class ArtifactoryShow < Knife::SupermarketShow

      dependency_loaders.concat(superclass.dependency_loaders)
      options.merge!(superclass.options)

      banner "knife artifactory show COOKBOOK [VERSION] (options)"
      category "artifactory"
    end
  end
end
