ActiveAdmin.register Contact do

  index do
    selectable_column
    id_column
    column :phone_no
    column :uuid
    column :passcode
    column "QR Code" do |contact|
      image_tag(contact.qr_code.url)
    end
    actions do |contact|
      link_to 'Send Message', send_message_admin_contact_path(contact), method: :post
    end
  end

  filter :phone_no

  form do |f|
    f.inputs "Contact" do
      f.input :phone_no
    end
    f.actions
  end

  show do |contact|
    attributes_table do
      row :phone_no
      row :uuid
      row :passcode
      row "QR Code" do
        image_tag(contact.qr_code.url)
      end
    end
  end

  action_item :only => :index do
    link_to 'Upload Phone Numbers', :action => 'upload_phone_numbers'
  end

  # Put Controller part here
  collection_action :upload_phone_numbers

  collection_action :import_contact, :method => :post do
    file = params[:contacts]
    begin
      case File.extname(file.original_filename)
      when '.csv'
        Contact.upload_csv(file)
        redirect_to :action => :index, :notice => "CSV imported successfully!" 
      when '.txt'
        Contact.upload_txt(file)
        redirect_to :action => :index, :notice => "CSV imported successfully!" 
      else 
        flash[:error] = "Unknown file type: #{file.original_filename}. Please upload .csv or .txt file"
        render "upload_phone_numbers"
      end
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      flash[:error] = "something wrong"
      render "upload_phone_numbers"
    end 
  end  

  batch_action :send_messages do |selection|
    contacts = Contact.where("id in(?)", params[:collection_selection])
    contacts.each do |contact|
      str = "Please click on the link "
      str << admin_contacts_url({uuid: contact.uuid}).to_s
      str << "\nYour passcode is #{contact.passcode}"
      begin
        Client.messages.create(from: '+12014686650', to: contact.phone_no, body: str)
      rescue Twilio::REST::RequestError => e
        logger.error "error #{e}"
      end
    end
    redirect_to admin_contacts_path, notice: 'Messages is send'
  end

  member_action :send_message, method: :post do
    contact = Contact.find(params[:id])
    message = create_message(contact)
    Contact.send_message(message, contact)
    redirect_to admin_contacts_path, notice: 'Message is sent'
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  permit_params :phone_no

  controller do
    def create_message(contact)
      str = "Please click on the link "
      str << admin_contacts_url({uuid: contact.uuid}).to_s
      str << "\nYour passcode is #{contact.passcode}"
    end
  end 

end
