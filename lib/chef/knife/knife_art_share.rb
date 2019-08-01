# The purpose of this class is double:
# 1. allow passing flags to the super class so that the do_upload method of this
#    class is called and that signing key verification is skipped by the underlying Chef::HTTP::Authenticator that's
#    used with the rest client (see comment below).
# 2. Override (monkey patch) the required methods in Chef::HTTP::Authenticator and Knife::SupermarketShare
#    to allow inserting our own logic that deploys a cookbook to Artifactory.
#
# The Supermarket API is kept (post /api/v1/cookbooks/cookbook_name) by Artifactory although it does not currently
# return a correct response (it simply returns 200) due to performance considerations.


require 'chef/knife'
require 'chef/knife/supermarket_share'

class Chef
  class Knife
    class ArtifactoryShare < Knife::SupermarketShare

      dependency_loaders.concat(superclass.dependency_loaders)
      options.merge!(superclass.options)

      banner "knife artifactory share COOKBOOK [CATEGORY] (options)"
      category "artifactory"

      alias_method :orig_run, :run
      alias_method :orig_get_category, :get_category
      alias_method :orig_do_upload, :do_upload

      def run
        begin
        # I'm forced to use threadlocal until we find a better solution... can't really find a way to pass configuration
        # down to the Chef::CookbookUploader, Chef::ServerAPI, Chef::HTTP or Chef::HTTP::Authenticator
        # (which are created one after another starting) with CookbookUploader to make it skip the signing key verification.
        # Can make the authenticator skip by passing load_signing_key(nil, nil) and opts[:sign_request] => false
        Thread.current[:artifactory_deploy] = 'yes'
        # Send artifactory deploy flag to super
        config[:artifactory_deploy] = true
        Chef::Log.debug("[KNIFE-ART] running site share with config: #{config}")
        orig_run
        ensure
          # always cleanup threadlocal
          Thread.current[:artifactory_deploy] = nil
        end
      end

      private

      # Pretty much copy paste of the original, just with authentication on the rest client...
      def get_category(cookbook_name)
        # Use Artifactory deployment logic only if flag sent by Artifactory plugin
        unless config[:artifactory_deploy]
          Chef::Log.debug('[KNIFE-ART] ArtifactoryShare::get_category called without artifactory flag, delegating to super')
          return orig_get_category(cookbook_name)
        end
        begin
          data = noauth_rest.get("#{config[:supermarket_site]}/api/v1/cookbooks/#{@name_args[0]}")
          if data.nil?
            return data["category"]
          else
            return 'Other'
          end
        rescue => e
          return "Other" if e.kind_of?(Net::HTTPServerException) && e.response.code == "404"
          ui.fatal("Unable to reach Supermarket: #{e.message}. Increase log verbosity (-VV) for more information.")
          Chef::Log.debug("\n#{e.backtrace.join("\n")}")
          exit(1)
        end

      end

      def do_upload(cookbook_filename, cookbook_category, user_id, user_secret_filename)
        # Use Artifactory deployment logic only if flag sent by Artifactory plugin
        unless config[:artifactory_deploy]
          Chef::Log.debug('[KNIFE-ART] ArtifactoryShare::do_upload called without artifactory flag, delegating to super')
          orig_do_upload(cookbook_filename, cookbook_category, user_id, user_secret_filename)
          return
        end
        # cookbook_filename is set as tempDir/cookbook_name in parent
        cookbook_name = cookbook_filename.split('/')[-1]
        uri = "#{config[:supermarket_site]}/api/v1/cookbooks/#{cookbook_name}"
        uri += "?category=#{cookbook_category}" if cookbook_category
        Chef::Log.debug("[KNIFE-ART] Deploying cookbook #{cookbook_name} to Artifactory url at #{uri}")
        # This guy throws an exception and consumes the request body upon non-ok http code, and deprives us of the
        # ability to do anything with the response itself... i'm letting the parent catch it and terminate.
        # debug log will be able to show the response Artifactory returned in case of errors.
        file_contents = File.open(cookbook_filename, "rb") { |f| f.read }
        # no need to send auth header here, 'normal' HTTP client uses url with credentials from config
        rest.post(uri, file_contents, {"content-type" => "application/x-binary"})
      end

    end
  end
end

# Chef::Http::Authenticator monkeypatch to allow skipping signing key verification when deploying to Artifactory
class Chef
  class HTTP
    class Authenticator

      alias_method :orig_load_signing_key, :load_signing_key

      def load_signing_key(key_file, raw_key = nil)
        Chef::Log.debug("[KNIFE-ART] global var: #{Thread.current[:artifactory_deploy]}")
        if Thread.current.key?(:artifactory_deploy) and Thread.current[:artifactory_deploy].eql? 'yes'
          Chef::Log.debug('[KNIFE-ART] Artifactory plugin substituting for Chef::Http::Authenticator --> omitting signing key usage')
          @sign_request = false
          @raw_key = ''
          @key = ''
        else
          # Artifactory flag not present, call original implementation
          orig_load_signing_key(key_file, raw_key)
        end
      end

    end
  end
end
