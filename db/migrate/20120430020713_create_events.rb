class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :started_at
      t.datetime :ended_at
      t.string :name

      t.timestamps
    end
  end
end
