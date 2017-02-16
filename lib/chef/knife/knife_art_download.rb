# Overrides the default Chef::Knife::CookbookSiteShare to allow basic authentication against an Artifactory backend.
# Ideally we would like to use a mechanism that allows injecting pluggable authentication middleware into the Chef::Http
# REST clients, but in the interest of allowing not-only-newest knife client versions to work with Artifactory we chose
# this solution for now.

require 'chef/knife'
require 'chef/knife/cookbook_site_download'
require 'knife-art/knife_art_utils'

class Chef
  class Knife
    class ArtifactoryDownload < Knife::CookbookSiteDownload

      dependency_loaders.concat(superclass.dependency_loaders)
      options.merge!(superclass.options)

      banner "knife artifactory download COOKBOOK [VERSION] (options)"
      category "artifactory"

      alias_method :orig_run, :run
      alias_method :orig_download_cookbook, :download_cookbook
      alias_method :orig_current_cookbook_data, :current_cookbook_data
      alias_method :orig_desired_cookbook_data, :desired_cookbook_data

      def run
        config[:artifactory_download] = true
        Chef::Log.debug("[KNIFE-ART] running site download with config: #{config}")
        orig_run
      end

      private

      def current_cookbook_data
        unless config[:artifactory_download]
          Chef::Log.debug('[KNIFE-ART] current_cookbook_data called without artifactory flag, delegating to super')
          return orig_current_cookbook_data
        end
        @current_cookbook_data ||= begin
          noauth_rest.get("#{cookbooks_api_url}/#{@name_args[0]}", auth_header)
        end
      end

      def desired_cookbook_data
        unless config[:artifactory_download]
          Chef::Log.debug('[KNIFE-ART] desired_cookbook_data called without artifactory flag, delegating to super')
          return orig_desired_cookbook_data
        end
        @desired_cookbook_data ||= begin
          uri = if @name_args.length == 1
                  current_cookbook_data["latest_version"]
                else
                  specific_cookbook_version_url
                end

          noauth_rest.get(uri, auth_header)
        end
      end

      def download_cookbook
        unless config[:artifactory_download]
          Chef::Log.debug('[KNIFE-ART] desired_cookbook_data called without artifactory flag, delegating to super')
          return orig_download_cookbook
        end
        ui.info "Downloading #{@name_args[0]} from Supermarket at version #{version} to #{download_location}"
        tf = noauth_rest.streaming_request(desired_cookbook_data["file"], auth_header)

        ::FileUtils.cp tf.path, download_location
        ui.info "Cookbook saved: #{download_location}"
      end

      def auth_header
        @auth_header ||= begin
                            ::Knife::KnifeArt::KnifeArtUtils.auth_header_from(cookbooks_api_url)
                         end
      end

    end
  end
end
