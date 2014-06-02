class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :birth_date, :full_name, :username, presence: true       
  
  belongs_to :recommender, :class_name => 'User' 
  belongs_to :parent, :class_name => 'User'
  belongs_to :left_branch, :class_name => 'User'
  belongs_to :right_branch, :class_name => 'User'
  has_one :sent_request, :class_name => 'JoinRequest', :foreign_key => "user_id"
  has_many :received_requests, :class_name => 'JoinRequest', :foreign_key => "receiver_id"
  has_many :gambles
  
  after_create :insert_in_gambtree
  
  def self.trunk
    @@trunk ||= User.find_by is_trunk: true
  end
  
  def gamble
    gambles.find_by gambgame: Gambgame.current
  end
  
  def smaller_branch
    if left_branch && right_branch
      left_branch.leaf_count <= right_branch.leaf_count ? left_branch : right_branch
    else
      nil
    end
  end
  
  def participates_with_branch? branch
    return false unless gamble && left_branch && right_branch
    
    left_gambfruits = left_branch.gambfruits
    right_gambfruits = right_branch.gambfruits
    participating_branch = left_gambfruits.length <= right_gambfruits.length ? left_branch : right_branch
    branch == participating_branch  
  end
  
  def leaf_count 
    1 + (left_branch ? left_branch.leaf_count : 0) + (right_branch ? right_branch.leaf_count : 0)
  end
  
  def pending_requests
    received_requests.where(:resolved => false)
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
  
  def participating_gambfruits calculate_possible_gambfruits=false
    if gamble
      gambfruits = [gamble.gambfruit]
    elsif calculate_possible_gambfruits
      gambfruits = []
    else
      return []
    end
    child_gambfruits = []
    if left_branch && right_branch
      left_gambfruits = left_branch.gambfruits
      right_gambfruits = right_branch.gambfruits
      child_gambfruits = left_gambfruits.length <= right_gambfruits.length ? left_gambfruits : right_gambfruits 
    end
    gambfruits + child_gambfruits
  end
  
  def gambfruits
    gambfruits = []
    gambfruits << gamble.gambfruit if gamble
    gambfruits += left_branch.gambfruits if left_branch
    gambfruits += right_branch.gambfruits if right_branch
    return gambfruits  
  end
  
  def get_winner_parents
    winner_parents = []
    unless parent.nil?
      winner_parents << parent if parent.participates_with_branch? self
      winner_parents += parent.get_winner_parents
    end
    return winner_parents
  end
  
  def get_gambtree
    gambtree = [{:lvl => 1, :posn => 0}] + self.get_leaves(2, 0)
    return gambtree
  end
  
  protected
  
  def insert_in_gambtree
    if User.trunk
      if recommender
        JoinRequest.create user: self, receiver: recommender, resolved: false
      else
        User.trunk.insert_leaf self
      end
    else
      self.is_trunk = true
      self.save
    end
  end
  
  def attach_leaf_to_me new_leaf
    new_leaf.parent = self
    new_leaf.save
    self.save
  end
  
  def get_leaves lvl, posn
    if left_branch.nil? && right_branch.nil?
      return []
    else
      branches = [left_branch, right_branch]
      leaves = []
      next_lvl_posn = posn * 2;
      is_left = true
      branches.each do |branch|
        if branch
          next_lvl_posn += 1 unless is_left
          leaves << {:lvl => lvl, :posn => next_lvl_posn}
          leaves += branch.get_leaves lvl+1, next_lvl_posn
        end
        is_left = false
      end
      return leaves
    end
  end
  
end
