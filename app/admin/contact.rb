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
    actions
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
    link_to 'Upload Phone Numbers', :action => 'upload_phone_number'
  end

  # Put Controller part here
  collection_action :upload_phone_number

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
end
