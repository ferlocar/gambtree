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
  
  before_create :downcase_fields
  after_create :insert_in_gambtree
  
  def after_database_authentication
    if (last_gambseed_gift_date + 15.days) < Time.now
      self.seeds += 15
      self.last_gambseed_gift_date = Time.now
      self.save
    end
  end
  
  def self.trunk
    User.find_by is_trunk: true
  end
  
  def gamble
    gambles.find_by gambgame: Gambgame.current
  end
  
  def is_gambling?
    !gamble.nil?
  end
  
  def gambfruits
    gambfruits = []
    gambfruits << gamble.gambfruit if gamble
    gambfruits += left_branch.gambfruits if left_branch
    gambfruits += right_branch.gambfruits if right_branch
    return gambfruits  
  end
  
  def gambfruit_branch_gambfruits
    return [] unless left_branch && right_branch
    left_gambfruits = left_branch.gambfruits
    right_gambfruits = right_branch.gambfruits
    left_gambfruits.length <= right_gambfruits.length ? left_gambfruits : right_gambfruits
  end
  
  def participating_gambfruits
    gamble ? [gamble.gambfruit] + gambfruit_branch_gambfruits : []
  end
  
  def gambfruit_branch
    return nil unless left_branch && right_branch
    
    left_gambfruits = left_branch.gambfruits
    right_gambfruits = right_branch.gambfruits
    left_gambfruits.length <= right_gambfruits.length ? left_branch : right_branch  
  end
  
  def participates_with_branch? branch
    gamble.present? && branch.present? && (branch == gambfruit_branch)
  end
  
  def winner_parents
    winner_parents = []
    unless parent.nil?
      winner_parents << parent if parent.participates_with_branch? self
      winner_parents += parent.winner_parents
    end
    return winner_parents
  end
  
  def leaf_count 
    1 + (left_branch ? left_branch.leaf_count : 0) + (right_branch ? right_branch.leaf_count : 0)
  end
  
  def smaller_branch
    if left_branch && right_branch
      left_branch.leaf_count <= right_branch.leaf_count ? left_branch : right_branch
    else
      nil
    end
  end
  
  def is_leaf?
    left_branch.nil? && right_branch.nil?
  end
  
  def pending_requests
    received_requests.where(:resolved => false)
  end
  
  def add_leaf new_leaf
    if left_branch && right_branch
      smaller_branch.add_leaf new_leaf
    else
      if left_branch.nil?
        self.left_branch = new_leaf
      else
        self.right_branch = new_leaf
      end
      new_leaf.parent = self
      new_leaf.save
      self.save
    end
  end
  
  def gambtree_struct lvl, posn, in_gambfruit_branch
    {lvl: lvl, posn: posn, name: username, gambling: is_gambling?, 
      used_by_player: in_gambfruit_branch && is_gambling?, is_leaf: is_leaf?}
  end
  
  def gambtree
    [gambtree_struct(1,0,is_gambling?)] + gambtree_leaves(2, 0, false)
  end
  
  protected
  
  def insert_in_gambtree
    if parent.nil?
      if User.trunk
        self.is_trunk = false
        if recommender
          JoinRequest.create user: self, receiver: recommender, resolved: false
        else
          User.trunk.add_leaf self
        end
      else
        self.is_trunk = true
      end
    end
    self.seeds = 15
    self.last_gambseed_gift_date = Time.now
    self.save
  end
  
  def gambtree_leaves lvl, posn, in_gambfruit_branch
    branches = [left_branch, right_branch]
    leaves = []
    branches.each do |branch|
      if branch
        in_gambfruit_branch = branch == gambfruit_branch if lvl == 2
        branch_posn = posn + (branch == right_branch ? 1 : 0)
        leaves << branch.gambtree_struct(lvl, branch_posn, in_gambfruit_branch)
        leaves += branch.gambtree_leaves lvl+1, branch_posn*2, in_gambfruit_branch
      end
    end
    return leaves
  end
  
  private
  
  def downcase_fields
    self.username.downcase!
  end
  
end
