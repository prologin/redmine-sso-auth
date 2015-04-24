require 'redmine'

Redmine::Plugin.register :redmine_sso_auth do
  name 'SSO authentication plugin'
  author 'Alexandre "Zopieux" Macabies'
  url ''
  description 'SSO authentication using HTTP header or environment variable'
  version '0.1'

  settings :partial => 'settings/redmine_sso_auth_settings',
    :default => {
      'enable' => 'true',
      'server_env_var' => 'HTTP_REMOTE_USER',
      'lookup_mode' => 'login',
      'keep_sessions' => 'false'
    }
end

RedmineApp::Application.config.after_initialize do
  unless ApplicationController.include? (RedmineSSOAuth::SSOAuthPatch)
    ApplicationController.send(:include, RedmineSSOAuth::SSOAuthPatch)
  end
end

