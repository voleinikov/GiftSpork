class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :exchange_id
      t.string :invited_email
      t.string :token

      t.timestamps
    end
  end
end
