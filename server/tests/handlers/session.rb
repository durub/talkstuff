class SessionTest < HandlerTest
  def setup
    $admin_keys = []
  end

  def test_new_session
    should_answer_with :action_number => ANS_NEW_SESSION, :success => 1, :user_id => 0
    call_handler_for NEW_SESSION
  end

  def test_valid_new_admin_session
    $admin_keys << "test_key"

    should_answer_with :success => 1, :user_id => 0
    call_handler_for NEW_ADMIN_SESSION, "test_key"
  end

  def test_invalid_admin_session
    $admin_keys << "test_key"

    should_answer_with :success => 0, :error_code => INVALID_KEY
    call_handler_for NEW_ADMIN_SESSION, "wrong_key"

    should_answer_with :success => 0, :error_code => INVALID_KEY
    call_handler_for NEW_ADMIN_SESSION
  end
end