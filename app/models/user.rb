  class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :confirmable

  has_many :profiles
  has_many :images
  has_one :user_photo, dependent: :destroy
  accepts_nested_attributes_for :user_photo


  has_many :user_events
  has_many :participated_events, through: :user_events, source: :event

  has_many :events

  def join!(event)
    participated_events << event
  end

  def quit!(event)
    participated_events.delete(event)
  end

  def is_member_of?(event)
    participated_events.include?(event)
  end

  def editable_by?(user, current_user)
    user && user == current_user
  end

end
