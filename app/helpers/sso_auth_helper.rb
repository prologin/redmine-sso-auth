module SSOAuthHelper
  unloadable
  
  def use_email?
    Setting.plugin_redmine_sso_auth['lookup_mode'] == 'mail'
  end

  def remote_user
    Rails.logger.debug 'attempting to build remote-user'
    request.env[Setting.plugin_redmine_sso_auth['server_env_var']]
  end

end
