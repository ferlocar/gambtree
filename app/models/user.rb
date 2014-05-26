class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :recommender, :class_name => 'User' 
  belongs_to :parent, :class_name => 'User'
  belongs_to :left_branch, :class_name => 'User'
  belongs_to :right_branch, :class_name => 'User'
  
  after_create :insert_in_gambtree
  
  def self.trunk
    @@trunk ||= User.find_by is_trunk: true
  end
  
  def smaller_branch
    if left_branch && right_branch
      left_branch.leaf_count <= right_branch.leaf_count ? left_branch : right_branch
    else
      nil
    end
  end
  
  def leaf_count 
    1 + (left_branch ? left_branch.leaf_count : 0) + (right_branch ? right_branch.leaf_count : 0)
  end
  
  protected
  
  def insert_in_gambtree
    if User.trunk
      User.trunk.insert_leaf self
    else
      self.is_trunk = true
    end
    self.save
  end
  
  def insert_leaf new_leaf
    if left_branch.nil?
      self.left_branch = new_leaf
      attach_leaf_to_me new_leaf
    elsif right_branch.nil?
      self.right_branch = new_leaf
      attach_leaf_to_me new_leaf
    else
      smaller_branch.insert_leaf new_leaf
    end
  end
  
  def attach_leaf_to_me new_leaf
    new_leaf.parent = self
    new_leaf.save
    self.save
  end
  
end
