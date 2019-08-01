# Overrides the default Chef::Knife::SupermarketInstall to allow basic authentication against an Artifactory backend.
# Ideally we would like to use a mechanism that allows injecting pluggable authentication middleware into the Chef::Http
# REST clients, but in the interest of allowing not-only-newest knife client versions to work with Artifactory we chose
# this solution for now.


require 'chef/knife'
require 'chef/knife/supermarket_install'

class Chef
  class Knife
    class ArtifactoryInstall < Knife::SupermarketInstall

      dependency_loaders.concat(superclass.dependency_loaders)
      options.merge!(superclass.options)

      banner "knife artifactory install COOKBOOK [VERSION] (options)"
      category "artifactory"

      alias_method :orig_run, :run
      alias_method :orig_download_cookbook_to, :download_cookbook_to

      def run
        config[:artifactory_install] = true
        Chef::Log.debug("[KNIFE-ART] running site install with config: #{config}")
        orig_run
      end

      private

      def download_cookbook_to(download_path)
        unless config[:artifactory_install]
          Chef::Log.debug('[KNIFE-ART] ArtifactoryInstall::download_cookbook_to called without artifactory flag, delegating to super')
          return orig_download_cookbook_to(download_path)
        end
        downloader = Chef::Knife::ArtifactoryDownload.new
        downloader.config[:file] = download_path
        downloader.config[:supermarket_site] = config[:supermarket_site]
        downloader.name_args = name_args
        downloader.run
        downloader
      end

    end
  end
end
