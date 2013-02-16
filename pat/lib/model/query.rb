class Query
  attr_accessor :user, :from, :to, :params
  
  def initialize(user)
    @user = user
  end
  
end
