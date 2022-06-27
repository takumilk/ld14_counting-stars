require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection
class User < ActiveRecord::Base
    has_secure_password
     validates :username,
      presence: true
     validates :password,
      length: {minimum: 5},
      format: {with:/(?=.*?[a-z])(?=.*?[0-9])/}
    has_many :counters
end

class Counter < ActiveRecord::Base
    belongs_to :user
end


