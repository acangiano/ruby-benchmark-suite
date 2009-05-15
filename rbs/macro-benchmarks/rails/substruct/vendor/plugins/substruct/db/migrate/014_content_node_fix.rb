# Removes ContentNodeTypes table, because that was a weird fucking
# hack that was put in before I knew about SingleTableInheritance.
#
class ContentNodeFix < ActiveRecord::Migration
  def self.up		
    # Add type column
    add_column :content_nodes, :type, :string, :limit => 50, :default => '', :null => false
    
    # Renaming 'Blog Post' to Blog for types...
    blog_node_type = ContentNodeType.find_by_name('Blog Post')
    blog_node_type.update_attribute('name', 'Blog')
    
    # Fill type column with appropriate type
    nodes = ContentNode.find(:all)
    for node in nodes do
      node_type = node.content_node_type.name
      node.update_attribute('type', node_type)
    end
    #
    drop_table :content_node_types
    remove_column :content_nodes, :content_node_type_id
    
    add_index :content_nodes, ['type', 'id'], :name => "type"
  end

  # Reverse all changes
  #
  #
  def self.down
    create_table(:content_node_types, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 50, :default => "", :null => false
    end
    ContentNodeType.create(:name => 'Blog')
    ContentNodeType.create(:name => 'Snippet')
    ContentNodeType.create(:name => 'Page')
    
    add_column :content_nodes, :content_node_type_id, :integer, :default => 1, :null => false
    # Refill content_node_type column
    nodes = ContentNode.find(:all)
    for node in nodes do
      node.update_attribute('content_node_type_id', ContentNodeType.find_by_name(node.type.to_s).id)
    end
    remove_column :content_nodes, :type
    # Move 'Blog' back to 'Blog Post'
    node_type = ContentNodeType.find_by_name('Blog')
    node_type.update_attribute('name', 'Blog Post')
    
    remove_index :content_nodes, :name => "type"
  end
end