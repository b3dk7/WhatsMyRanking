class AddServicetypeToRecords < ActiveRecord::Migration
  def change
    add_column :records, :servicetype, :string
  end
end
