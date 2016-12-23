class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :name
      t.string :filter
      t.string :class_name

      t.timestamps
    end
  end
end
