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
end
