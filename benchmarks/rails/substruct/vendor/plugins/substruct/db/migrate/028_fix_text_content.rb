# MySql 'community' on XP barfs when we try to create 
# text fields with default values. 
#
# Hopefully this fixed things.
#
class FixTextContent < ActiveRecord::Migration
  def self.up
    change_column :content_nodes, :content, :text
    change_column :items, :description, :text
    change_column :questions, :long_question, :text
    change_column :sessions, :data, :text
  end
  
  def self.down
    change_column :content_nodes, :content, :text, :default => '', :null => false
    change_column :items, :description, :text, :default => '', :null => false
    change_column :questions, :long_question, :text, :default => '', :null => false
    change_column :sessions, :data, :text, :default => '', :null => false
  end
end