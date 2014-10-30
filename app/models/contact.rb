class Contact < ActiveRecord::Base

  has_attached_file :qr_code

  before_create :create_other_attributes

  def create_other_attributes
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.passcode = Devise.friendly_token.first(8)
  end
end
