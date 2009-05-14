# Adds tag grouping functionality
#
class TagGrouping < ActiveRecord::Migration
  def self.up
    add_column :tags, :rank, :integer
    add_column :tags, :parent_id, :integer, :default => 0, :null => false
  end
  
  def self.down
    remove_column :items, :rank
    remove_column :items, :parent_id
  end
end