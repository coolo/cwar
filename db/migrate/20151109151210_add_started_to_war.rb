class AddStartedToWar < ActiveRecord::Migration
  def change
    add_column :wars, :started, :boolean, default: :false, null: false
  end
end
