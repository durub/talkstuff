class SessionTest < HandlerTest
  def setup
    @data = {:admin_keys => ["test_key"]}
    @data[:user_list] = mock("User list")
  end

  def test_new_session
    @data[:user_list].expects(:add_user).with do |user|
      !user.admin?
    end

    should_answer_with :action_number => ANS_NEW_SESSION, :success => 1, :user_id => 0
    call_handler_for NEW_SESSION, [], @data
  end

  def test_valid_new_admin_session
    @data[:user_list].expects(:add_user).with do |user|
      user.admin?
    end

    should_answer_with :success => 1, :user_id => 0
    call_handler_for NEW_ADMIN_SESSION, "test_key", @data
  end

  def test_invalid_admin_session
    should_answer_with :success => 0, :error_code => INVALID_KEY
    call_handler_for NEW_ADMIN_SESSION, "wrong_key", @data

    should_answer_with :success => 0, :error_code => INVALID_KEY
    call_handler_for NEW_ADMIN_SESSION, [], @data
  end
end