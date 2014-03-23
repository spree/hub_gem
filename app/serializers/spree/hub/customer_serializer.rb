require 'active_model/serializer'

module Spree
  module Hub
    class CustomerSerializer < ActiveModel::Serializer
      attributes :id, :email, :sign_in_count, :reset_password_sent_at, :reset_password_token, :dob, :firstname, :lastname , :current_sign_in_at, :last_sign_in_at, :newsletter_on  
    end
  end
end