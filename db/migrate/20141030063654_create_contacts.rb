class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :phone_no
      t.string :uuid
      t.string :passcode
      t.attachment :qr_code
      t.boolean :is_invalid, default: false
      t.integer :attempted_count, default: 0

      t.timestamps
    end
  end
end
