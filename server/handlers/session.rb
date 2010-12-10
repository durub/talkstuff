NEW_SESSION = 0x10
NEW_ADMIN_SESSION = 0x11
ANS_NEW_SESSION = 0x12
INVALID_KEY = 0x666

class SessionHandler < PacketHandler
  handle NEW_SESSION do
    server[:user_list].add_user User.new

    answer_with :action_number => ANS_NEW_SESSION, :success => 1, :user_id => 0
  end

  handle NEW_ADMIN_SESSION do
    secret_key = payload
    admin_keys = server[:admin_keys]

    if !admin_keys.nil? && admin_keys.include?(secret_key)
      admin = User.new(:admin => true)
      server[:user_list].add_user admin

      answer_with :success => 1, :user_id => 0
    else
      answer_with :success => 0, :error_code => INVALID_KEY
    end
  end
end