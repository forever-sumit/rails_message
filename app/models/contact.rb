class Contact < ActiveRecord::Base

  has_attached_file :qr_code
  validates_attachment :qr_code, content_type: { content_type: /\Aimage\/.*\Z/ }

  validates_presence_of :phone_no
  before_create :validate_phone, if: "!phone_no.blank?"
  before_create :create_other_attributes
  before_create :generate_qrcode
  after_create :delete_temp_qrcode
  before_update :make_code_invalid

  def self.upload_csv(csv_data)
    CSV.foreach(csv_data.path, :headers => false) do |row|
      row.compact.each do |cdata|
        self.create(phone_no: cdata.strip)
      end
    end
  end

  def self.upload_txt(txt_data)
    file_data = txt_data.read.split(",\n")
    file_data.each do |data|
      self.create(phone_no: data.strip)
    end
  end

  def send_message(message)
    begin
      Client.messages.create(from: '+12014686650', to: self.phone_no, body: message)
      self.sent_at = DateTime.now
      self.save
    rescue Twilio::REST::RequestError => e
      logger.error "error #{e}"
    end
  end

  def is_valid_url?
    !is_invalid
  end

  def regenerate_data()
    self.passcode = Devise.friendly_token.first(8)
    self.attempted_count = 0
    self.is_invalid = false
    self.save
  end

  private

  def create_other_attributes
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.passcode = Devise.friendly_token.first(8)
  end

  def generate_qrcode
    qr = RQRCode::QRCode.new( self.uuid, :size => 10, :level => :l )
    png = qr.to_img
    file_name = Rails.root.to_s + "/public/" + SecureRandom.hex(32) + ".png"
    png.resize(90, 90).save(file_name)
    file = File.open(file_name)
    self.qr_code = file
  end

  def delete_temp_qrcode
    file_name = Rails.root.to_s + "/public/" + self.qr_code.original_filename
    File.delete(file_name)
  end

  def make_code_invalid
    self.is_invalid = true if self.attempted_count == 10
  end

  def validate_phone
    if Phonie::Phone.parse self.phone_no
      self.phone_no = "+#{self.phone_no}" unless self.phone_no.include?('+')
    else
      self.errors.add(:phone_no, "#{self.phone_no} is not a valid number.")
      return false
    end
    true
  end

end
