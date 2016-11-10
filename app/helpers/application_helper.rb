module ApplicationHelper

    # 假如所给用户是当前用户，返回true。
  def current_user?(user)
    user == current_user
  end

  def user_image(user, img_size, class_name)
    image_size = img_size||80
    if user.image.nil? then
      image_tag(user.gravatar_url(size: image_size, default: 'http://i.imgur.com/fclemsW.jpg'),size: image_size, class: class_name)
    else
      image_tag(user.image, size: image_size, class: class_name)
    end
  end
end
