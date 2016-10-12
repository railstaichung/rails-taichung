module ApplicationHelper

    # 假如所给用户是当前用户，返回true。
  def current_user?(user)
    user == current_user
  end
end
