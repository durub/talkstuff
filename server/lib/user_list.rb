class UserList
  def initialize
    @list = []
  end

  def add_user(user)
    @list << user
  end

  def remove_user(user)
    @list.delete user
  end

  def each_user(&blk)
    @list.each &blk
  end

  def each_admin
    @list.each do |user|
      yield user if user.admin?
    end
  end

  def number_of_users
    @list.length
  end
end