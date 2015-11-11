class AddDoneToWar < ActiveRecord::Migration
  def change
	  add_column :wars, :done, :boolean, default: :false
  end
end
