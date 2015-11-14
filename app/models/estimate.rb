class Estimate < ActiveRecord::Base
  belongs_to :user
  belongs_to :warrior

  def user_name
    User.name_for(self.user_id)
  end
  
end
