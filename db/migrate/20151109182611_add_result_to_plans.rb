class AddResultToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :th, :boolean, null: true
    add_column :plans, :percent, :integer, null: true
    add_column :plans, :stars, :integer, null: true
  end
end
