NEW_SESSION = 0x10
NEW_ADMIN_SESSION = 0x11
ANS_NEW_SESSION = 0x12
INVALID_KEY = 0x666

class SessionHandler < PacketHandler
  handle NEW_SESSION do
    answer_with :action_number => ANS_NEW_SESSION, :success => 1, :user_id => 0
  end

  handle NEW_ADMIN_SESSION do |payload|
    secret_key = payload[0][0]

    if $admin_keys.include?(secret_key)
      answer_with :success => 1, :user_id => 0
    else
      answer_with :success => 0, :error_code => INVALID_KEY
    end
  end
end