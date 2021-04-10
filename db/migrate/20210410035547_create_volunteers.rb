class CreateVolunteers < ActiveRecord::Migration[6.1]
  def change
    create_table :volunteers do |t|
      t.integer :requester_id
      t.belongs_to :request
      t.belongs_to :user

      t.timestamps
    end
  end
end
