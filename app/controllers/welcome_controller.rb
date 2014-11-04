class WelcomeController < ApplicationController
  before_action :get_contact, except: :index
  before_action :check_session, only: :get_qr_code
  def index
  end

  def enter_passcode
    raise ActiveRecord::RecordNotFound if @contact.blank?
  end

  def check_passcode
    if @contact.passcode == params[:passcode]
      @contact.update_attribute(:attempted_count, 0)
      gflash :success => "Congratulations! you have got your QR Code."
      session[:is_visited] = true
      redirect_to get_qr_code_path(uuid: @contact.uuid)
    else
      attempt_count = @contact.attempted_count.blank? ? 0 : @contact.attempted_count + 1
      @contact.update_attribute(:attempted_count, attempt_count)
      gflash :error => "Invalide passcode for given url."
      redirect_to enter_passcode_path(uuid: @contact.uuid)
    end
  end

  def get_qr_code
    session[:is_visited] = nil
  end

  private
    def check_session
      redirect_to enter_passcode_path(uuid: @contact.uuid) unless session[:is_visited]
    end

    def get_contact
      @contact = Contact.find_by_uuid(params[:uuid])
    end
end
