module RedmineSSOAuth
  module SSOAuthPatch
    unloadable

    def self.included(base)
      base.send(:include, ClassMethods)
      base.class_eval do
        alias_method_chain(:find_current_user, :ssoauth)
      end
    end

    module ClassMethods

      def use_email?
        Setting.plugin_redmine_sso_auth['lookup_mode'] == 'mail'
      end

      def remote_user
        Rails.logger.debug 'attempting to build remote-user'
        request.env[Setting.plugin_redmine_sso_auth['server_env_var']]
      end

      def find_current_user_with_ssoauth
        user = find_current_user_without_ssoauth
        return user unless Setting.plugin_redmine_sso_auth['enable'] == "true"

        remote_username = remote_user
        if remote_username.nil?
          if !used_sso_authentication? || Setting.plugin_redmine_sso_auth['keep_sessions'] == "true"
            return user
          end
          reset_session
          return nil
        end

        return user unless session_changed? user, remote_username

        reset_session
        try_login remote_username
      end

      def try_login(remote_username)
        if use_email?
          user = User.active.find_by_mail remote_username
        else
          user = User.active.find_by_login remote_username
        end
        if user.nil?
          flash[:error] = l :error_unknown_user
          return nil
        else
          do_login user
        end
      end

      def used_sso_authentication?
        session[:sso_authentication] == true
      end

      def session_changed?(user, remote_username)
        if user.nil?
          true
        else
          use_email? ? user.mail.casecmp(remote_username) != 0 : user.login.casecmp(remote_username) != 0
        end
      end

      def do_login(user)
        if (user && user.is_a?(User))
          start_user_session(user)
          user
        end
      end
    end
  end
end
