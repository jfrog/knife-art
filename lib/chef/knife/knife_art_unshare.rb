# More or less copy-pasted from cookbook_site_unshare because the http call happens inside the run method, not much
# sense in extending it

require "chef/knife"

class Chef
  class Knife
    class ArtifactoryUnshare < Knife

      deps do
        require "chef/json_compat"
      end

      banner "knife artifactory unshare COOKBOOK VERSION"
      category "artifactory"

      option :supermarket_site,
             short: "-m SUPERMARKET_SITE",
             long: "--supermarket-site SUPERMARKET_SITE",
             description: "Supermarket Site",
             default: "https://supermarket.chef.io",
             proc: Proc.new { |supermarket| Chef::Config[:knife][:supermarket_site] = supermarket }

      def run
        @cookbook_name = @name_args[0]
        if @cookbook_name.nil?
          show_usage
          ui.fatal "You must provide the name of the cookbook to unshare"
          exit 1
        end
        @cookbook_version = @name_args[1]
        if @cookbook_version.nil?
          show_usage
          ui.fatal "You must provide a version to unshare"
          exit 1
        end

        confirm "Are you sure you want to delete version #{@cookbook_version} of the cookbook #{@cookbook_name} from Artifactory"

        begin
          url = "#{cookbooks_api_url}/#{@cookbook_name}/#{@cookbook_version}"
          noauth_rest.delete(url, auth_header)
        rescue Net::HTTPServerException => e
          raise e unless e.message =~ /Forbidden/ || e.message =~ /Unauthorized/
          ui.error "Forbidden: You must have delete permissions on the target repo to delete #{@cookbook_name}."
          exit 1
        end

        ui.info "Deleted version #{@cookbook_version} of the cookbook #{@cookbook_name}"
      end

      private

      def cookbooks_api_url
        "#{config[:supermarket_site]}/api/v1/cookbooks"
      end

      def auth_header
        @auth_header ||= begin
          ::KnifeArtifactory::Utils.auth_header_from(cookbooks_api_url)
        end
      end

    end
  end
end
