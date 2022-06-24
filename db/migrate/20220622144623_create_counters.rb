class CreateCounters < ActiveRecord::Migration[6.1]
  def change
    create_table :counters do |t|
    t.string :countername
    t.integer :counter_number
    t.string :img
    t.integer :user_id
    t.timestamps null: false
  end
 end
end
