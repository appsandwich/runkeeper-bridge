class CreateSleeps < ActiveRecord::Migration
  def change
    create_table :sleeps do |t|

      t.timestamps
    end
  end
end
