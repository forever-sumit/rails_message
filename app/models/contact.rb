class Contact < ActiveRecord::Base

  has_attached_file :qr_code
  validates_attachment :qr_code, content_type: { content_type: /\Aimage\/.*\Z/ }

  before_create :create_other_attributes
  before_create :generate_qrcode
  after_create :delete_temp_qrcode

  def create_other_attributes
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.passcode = Devise.friendly_token.first(8)
  end

  def self.upload_csv(csv_data)
    CSV.foreach(csv_data.path, :headers => false) do |row|
      row.compact.each do |cdata|
        self.create!(phone_no: cdata.strip)
      end
    end 
  end

  def self.upload_txt(txt_data)
    file_data = txt_data.read.split(",\n")
    file_data.each do |data|
      self.create!(phone_no: data.strip)
    end
  end

  def self.send_message(message, contact)
    begin
      Client.messages.create(from: '+12014686650', to: contact.phone_no, body: message)
    rescue Twilio::REST::RequestError => e
      logger.error "error #{e}"
    end
  end

  private

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

end
