class AddColumnSendAtToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :sent_at, :datetime
  end
end
