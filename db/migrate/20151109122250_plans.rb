class Plans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      # who added the plan (auditing)
      t.belongs_to :user 
      t.belongs_to :warrior
      t.integer :base
      t.string :state
      t.timestamps null: false
    end
  end
end
