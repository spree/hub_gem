require 'active_model/serializer'

module Spree
  module Hub
    class CustomerSerializer < ActiveModel::Serializer
      attributes :id, :email, :sign_in_count, :password_reset_on, :dob, :firstname, :lastname , :current_sign_in_at, :last_sign_in_at, :newsletter_on  

      def password_reset_on
        object.reset_password_sent_at
        nil
      end

    end
  end
end