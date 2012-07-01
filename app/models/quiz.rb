class Quiz < ActiveRecord::Base
  attr_accessible :ans1, :ans2, :ans3, :ans4, :correct, :question, :title, :user_id
end
