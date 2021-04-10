class CreateRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :requests do |t|
      t.string :title
      t.string :need
      t.text :description
      t.float :lat
      t.float :lng
      t.string :address
      t.integer :status
      t.boolean :republish
      t.belongs_to :user

      t.timestamps
    end
  end
end
