require 'rails_helper'

RSpec.describe User, :type => :model do
  User.delete_all
  let!(:root_user){User.trunk || FactoryGirl.create(:user)}
  let!(:left_branch){root_user.left_branch || FactoryGirl.create(:user)}
  let!(:right_branch){root_user.right_branch || FactoryGirl.create(:user)}
  let(:new_user){FactoryGirl.create(:user)}
  let(:gamble){FactoryGirl.create(:gamble)}
  let(:old_gamble){FactoryGirl.create(:old_gamble)}
  let(:recommender){FactoryGirl.create(:user, recommender: new_user).sent_request.receiver}
  let(:recommender_no_pending) do
    usr = recommender
    usr.pending_requests.each do |request| 
      request.resolved = true
      request.save
    end
    return usr
  end
  let(:recommended_user){recommender.received_requests.first.user}
  
  let(:gambtree_trunk) do
    return root_user if $gambtree_initialized
    root_user.inspect 
    left_branch.inspect
    right_branch.inspect
    lvl2_psn0 = FactoryGirl.create(:user)
    lvl2_psn2 = FactoryGirl.create(:user)
    lvl2_psn1 = FactoryGirl.create(:user)
    lvl2_psn3 = FactoryGirl.create(:user)
    # gambling_user_one_level
    lvl3_psn0 = FactoryGirl.create(:user, parent: lvl2_psn0)
    FactoryGirl.create(:gamble, user: lvl3_psn0)
    lvl2_psn0.left_branch = lvl3_psn0
    attach_gamblers lvl3_psn0
    # gambling_user_no_left
    lvl3_psn1 = FactoryGirl.create(:user, parent: lvl2_psn0)
    FactoryGirl.create(:gamble, user: lvl3_psn1)
    lvl2_psn0.right_branch = lvl3_psn1
    lvl3_psn1.right_branch = FactoryGirl.create(:gamble, user: FactoryGirl.create(:user, parent: lvl3_psn1)).user
    lvl3_psn1.save
    # gambling_user_no_right
    lvl3_psn2 = FactoryGirl.create(:user, parent: lvl2_psn1)
    FactoryGirl.create(:gamble, user: lvl3_psn2)
    lvl2_psn1.left_branch = lvl3_psn2
    lvl3_psn2.left_branch = FactoryGirl.create(:gamble, user: FactoryGirl.create(:user, parent: lvl3_psn2)).user
    lvl3_psn2.save
    # gambling_user_unbalanced_left
    lvl3_psn3 = FactoryGirl.create(:user, parent: lvl2_psn1)
    FactoryGirl.create(:gamble, user: lvl3_psn3)
    lvl2_psn1.right_branch = lvl3_psn3
    attach_gamblers lvl3_psn3
    attach_gamblers lvl3_psn3.right_branch
    # gambling_user_unbalanced_right
    lvl3_psn4 = FactoryGirl.create(:user, parent: lvl2_psn2)
    FactoryGirl.create(:gamble, user: lvl3_psn4)
    lvl2_psn2.left_branch = lvl3_psn4
    attach_gamblers lvl3_psn4
    attach_gamblers lvl3_psn4.left_branch
    # user_with_gambling_children
    lvl3_psn5 = FactoryGirl.create(:user, parent: lvl2_psn2)
    lvl2_psn2.right_branch = lvl3_psn5
    attach_gamblers lvl3_psn5
    [lvl3_psn5.left_branch,lvl3_psn5.right_branch].each {|branch| attach_gamblers branch}
    # gambling_user_with_gambling_children
    lvl3_psn6 = FactoryGirl.create(:user, parent: lvl2_psn3)
    lvl2_psn3.left_branch = lvl3_psn6
    FactoryGirl.create(:gamble, user: lvl3_psn6)
    attach_gamblers lvl3_psn6
    [lvl3_psn6.left_branch,lvl3_psn6.right_branch].each {|branch| attach_gamblers branch}
    # no_gambler
    lvl3_psn7 = FactoryGirl.create(:user, parent: lvl2_psn3)
    lvl2_psn3.right_branch = lvl3_psn7
    
    lvl2_psn0.save
    lvl2_psn1.save
    lvl2_psn2.save
    lvl2_psn3.save
    $gambtree_initialized = true
    # puts User.all.map{|usr| "usr:#{usr.username}|left:#{usr.left_branch ? usr.left_branch.username : 'nil'}|right:#{usr.right_branch ? usr.right_branch.username : 'nil'}"}.inspect
    root_user.reload
    return root_user
  end
  let(:gambler) do
    return gambling_user_one_level.left_branch
  end
  let(:gambling_user_one_level) do
    return gambtree_trunk.left_branch.left_branch.left_branch
  end
  let(:gambling_user_no_left) do
    return gambtree_trunk.left_branch.left_branch.right_branch
  end
  let(:gambling_user_no_right) do
    return gambtree_trunk.left_branch.right_branch.left_branch
  end
  let(:gambling_user_unbalanced_left) do
    return gambtree_trunk.left_branch.right_branch.right_branch
  end
  let(:gambling_user_unbalanced_right) do
    return gambtree_trunk.right_branch.left_branch.left_branch
  end
  let(:user_with_gambling_children) do
    return gambtree_trunk.right_branch.left_branch.right_branch
  end
  let(:gambling_user_with_gambling_children) do
    return gambtree_trunk.right_branch.right_branch.left_branch
  end
  let(:no_gambler) do
    return gambtree_trunk.right_branch.right_branch.right_branch
  end
  
  def attach_gamblers usr
    left_gamble = FactoryGirl.create(:gamble, user: FactoryGirl.create(:user, parent: usr))
    right_gamble = FactoryGirl.create(:gamble, user: FactoryGirl.create(:user, parent: usr))
    usr.left_branch = left_gamble.user
    usr.right_branch = right_gamble.user
    usr.save
  end
  
  def check_children_gambfruit gambfruits, user
    [user.left_branch, user.right_branch].each do |branch|
      if branch
        expect(gambfruits).to include(branch.gamble.gambfruit)
        check_children_gambfruit gambfruits, branch
      end
    end
  end
  
  describe '.gambfruits' do
    context "returns empty array if no gamble and no children" do
      it{expect(no_gambler.gambfruits).to be_empty}
    end
    
    context "returns children gambfruits if no gamble but children are gambling" do
      it do
        user = user_with_gambling_children
        check_children_gambfruit user.gambfruits, user
        expect(user.gambfruits.length).to eq 6
      end
    end
    
    context "returns single element if gamble and no left or right branch" do
      it do
        expect(gambler.gambfruits[0]).to eq gambler.gamble.gambfruit
        expect(gambler.gambfruits.length).to eq 1
      end
    end
    
    context "returns user gambfruit and gambfruits in left and right branch" do
      it do
        user = gambling_user_with_gambling_children
        check_children_gambfruit user.gambfruits, user
        expect(user.gambfruits.length).to eq 7
      end
    end
  end
  
  describe '.gambfruit_branch_gambfruits' do
    context "returns empty array if no right branch" do
      it{expect(gambling_user_no_right.gambfruit_branch_gambfruits).to be_empty}
    end
    
    context "returns empty array if no left branch" do
      it{expect(gambling_user_no_left.gambfruit_branch_gambfruits).to be_empty}
    end
    
    context "returns gambfruits in left branch if it has less than the right branch" do
      it do 
        user = gambling_user_unbalanced_left
        check_children_gambfruit user.gambfruit_branch_gambfruits, user.left_branch
        expect(user.gambfruit_branch_gambfruits.length).to eq 1
      end
    end
    
    context "returns gambfruits in left branch if it has the same than the right branch" do
      it do 
        user = gambling_user_with_gambling_children
        check_children_gambfruit user.gambfruit_branch_gambfruits, user.left_branch
        expect(user.gambfruit_branch_gambfruits.length).to eq 3
      end
    end
    
    context "returns gambfruits in right branch if it has less than the left branch" do
      it do 
        user = gambling_user_unbalanced_right
        check_children_gambfruit user.gambfruit_branch_gambfruits, user.right_branch
        expect(user.gambfruit_branch_gambfruits.length).to eq 1
      end
    end
  end
  
  describe '.participating_gambfruits' do
    context "returns empty array if the user doesn't have a gamble" do
      it{expect(no_gambler.participating_gambfruits).to be_empty}
      it{expect(user_with_gambling_children.participating_gambfruits).to be_empty}
    end
    
    context "returns the user gambfruit and the gambfruits in the gambfruit branch" do
      it do 
        user = gambling_user_with_gambling_children
        gambfruits = user.participating_gambfruits
        check_children_gambfruit gambfruits, user.left_branch
        expect(gambfruits).to include user.gamble.gambfruit
        expect(gambfruits.length).to eq 4
      end
    end
  end
  
  describe '.participates_with_branch?' do
    context "returns false if the user doesn't have a gamble" do
      it do 
        usr = user_with_gambling_children
        expect(usr.participates_with_branch? usr.left_branch).to be false
        expect(usr.participates_with_branch? usr.right_branch).to be false
      end
    end
    
    context "returns false if the left branch is nil" do
      it do 
        usr = gambling_user_no_left
        expect(usr.participates_with_branch? usr.left_branch).to be false
        expect(usr.participates_with_branch? usr.right_branch).to be false
      end
    end
    
    context "returns false if the right branch is nil" do
      it do 
        usr = gambling_user_no_right
        expect(usr.participates_with_branch? usr.left_branch).to be false
        expect(usr.participates_with_branch? usr.right_branch).to be false
      end
    end
    
    context "returns true for left, false for right if unbalanced left" do
      it do 
        usr = gambling_user_unbalanced_left
        expect(usr.participates_with_branch? usr.left_branch).to be true
        expect(usr.participates_with_branch? usr.right_branch).to be false
      end
    end
    
    context "returns true for left, false for right if balanced" do
      it do 
        usr = gambling_user_one_level
        expect(usr.participates_with_branch? usr.left_branch).to be true
        expect(usr.participates_with_branch? usr.right_branch).to be false
      end
    end
    
    context "returns false for left, true for right if unbalanced right" do
      it do 
        usr = gambling_user_unbalanced_right
        expect(usr.participates_with_branch? usr.left_branch).to be false
        expect(usr.participates_with_branch? usr.right_branch).to be true
      end
    end
  end
  
  describe '.winner_parents' do

    context "returns empty array if user has no parents" do
      it{expect(root_user.winner_parents).to be_empty}
    end
    
    context "does not return parent if not in parent's gambfruit branch" do
      it {expect(gambling_user_unbalanced_left.right_branch.winner_parents).to be_empty}
    end
    
    context "does not return parent if parent didn't have a gamble" do
      it{expect(user_with_gambling_children.left_branch.winner_parents).to be_empty}
    end
    
    context "returns parent and grandparent if they had the user in their participating branch AND had a gamble" do
      it do
        winner = gambling_user_with_gambling_children.left_branch.left_branch
        winner_parents = winner.winner_parents
        expect(winner_parents).to include winner.parent
        expect(winner_parents).to include winner.parent.parent
        expect(winner_parents.length).to eq 2
      end
    end
  end
  
  describe '.leaf_count' do
    context "returns 1 if it has no branches" do
      it{expect(no_gambler.leaf_count).to eq 1}
    end
    
    context "returns 2 if it has a left branch" do
      it{expect(gambling_user_no_right.leaf_count).to eq 2}
    end
    
    context "returns 2 if it has a right branch" do
      it{expect(gambling_user_no_left.leaf_count).to eq 2}
    end
    
    context "returns the number of leaves in its branches plus 1" do
      it{expect(user_with_gambling_children.leaf_count).to eq 7}
    end
  end
  
  # smaller_branch tests
  
  describe '.smaller_branch' do
    context "returns nil if it doesn't have a left branch" do
      it{expect(gambling_user_no_left.smaller_branch).to be_nil}
    end
    
    context "returns nil if it doesn't have a right branch" do
      it{expect(gambling_user_no_right.smaller_branch).to be_nil}
    end
    
    context "returns left branch if it has less leaves than the right branch" do
      it{expect(gambling_user_unbalanced_left.smaller_branch).to be gambling_user_unbalanced_left.left_branch}
    end
    
    context "returns right branch if it has less leaves than the left branch" do
      it{expect(gambling_user_unbalanced_right.smaller_branch).to be gambling_user_unbalanced_right.right_branch}
    end
    
    context "returns left branch if both branches have the same amount of leaves" do
      it{expect(gambling_user_one_level.smaller_branch).to be gambling_user_one_level.left_branch}
    end
  end
  
  describe '.is_leaf?' do
    context "returns false if left branch is not nil" do
      it{expect(gambling_user_no_right.is_leaf?).to be false}
    end
    
    context "returns false if right branch is not nil" do
      it{expect(gambling_user_no_left.is_leaf?).to be false}
    end
    
    context "returns true if left branch and right branch are nil" do
      it{expect(no_gambler.is_leaf?).to be true}
    end
  end
  
  describe '.gambtree' do
    context "returns single element if leaf" do
      it{expect(no_gambler.gambtree).to include lvl: 1, posn: 0, name: no_gambler.username, gambling: false, used_by_player: false, is_leaf: true}
      it{expect(no_gambler.gambtree.length).to eq 1}
    end
    
    context "returns two elements if only left branch" do
      it{expect(gambling_user_no_right.gambtree).to include lvl: 1, posn: 0, name: gambling_user_no_right.username, gambling: true, used_by_player: true, is_leaf: false}
      it{expect(gambling_user_no_right.gambtree).to include lvl: 2, posn: 0, name: gambling_user_no_right.left_branch.username, gambling: true, used_by_player: false, is_leaf: true}
      it{expect(gambling_user_no_right.gambtree.length).to eq 2}
    end
    
    context "returns two elements if only right branch" do
      it{expect(gambling_user_no_left.gambtree).to include lvl: 1, posn: 0, name: gambling_user_no_left.username, gambling: true, used_by_player: true, is_leaf: false}
      it{expect(gambling_user_no_left.gambtree).to include lvl: 2, posn: 1, name: gambling_user_no_left.right_branch.username, gambling: true, used_by_player: false, is_leaf: true}
      it{expect(gambling_user_no_left.gambtree.length).to eq 2}
    end
    
    context "returns gambtree with correct structure for each node" do
      it do
        gambtree = root_user.gambtree
        # Lvl 1
        expect(gambtree).to include lvl: 1, posn: 0, name: root_user.username, gambling: false, used_by_player: false, is_leaf: false
        # Lvl 2
        expect(gambtree).to include lvl: 2, posn: 0, name: root_user.left_branch.username, gambling: false, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 2, posn: 1, name: root_user.right_branch.username, gambling: false, used_by_player: false, is_leaf: false
        # Lvl 3
        expect(gambtree).to include lvl: 3, posn: 0, name: root_user.left_branch.left_branch.username, gambling: false, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 3, posn: 1, name: root_user.left_branch.right_branch.username, gambling: false, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 3, posn: 2, name: root_user.right_branch.left_branch.username, gambling: false, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 3, posn: 3, name: root_user.right_branch.right_branch.username, gambling: false, used_by_player: false, is_leaf: false
        # gambling_user_one_level
        usr = gambling_user_one_level
        expect(gambtree).to include lvl: 4, posn: 0, name: usr.username, gambling: true, used_by_player: true, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 0, name: usr.left_branch.username, gambling: true, used_by_player: true, is_leaf: true
        expect(gambtree).to include lvl: 5, posn: 1, name: usr.right_branch.username, gambling: true, used_by_player: true, is_leaf: true
        # gambling_user_no_left
        usr = gambling_user_no_left
        expect(gambtree).to include lvl: 4, posn: 1, name: usr.username, gambling: true, used_by_player: true, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 3, name: usr.right_branch.username, gambling: true, used_by_player: true, is_leaf: true
        # gambling_user_no_right
        usr = gambling_user_no_right
        expect(gambtree).to include lvl: 4, posn: 2, name: usr.username, gambling: true, used_by_player: true, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 4, name: usr.left_branch.username, gambling: true, used_by_player: true, is_leaf: true
        # gambling_user_unbalanced_left
        usr = gambling_user_unbalanced_left
        expect(gambtree).to include lvl: 4, posn: 3, name: usr.username, gambling: true, used_by_player: true, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 6, name: usr.left_branch.username, gambling: true, used_by_player: true, is_leaf: true
        expect(gambtree).to include lvl: 5, posn: 7, name: usr.right_branch.username, gambling: true, used_by_player: true, is_leaf: false
        expect(gambtree).to include lvl: 6, posn: 14, name: usr.right_branch.left_branch.username, gambling: true, used_by_player: true, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 15, name: usr.right_branch.right_branch.username, gambling: true, used_by_player: true, is_leaf: true
        # gambling_user_unbalanced_right
        usr = gambling_user_unbalanced_right
        expect(gambtree).to include lvl: 4, posn: 4, name: usr.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 8, name: usr.left_branch.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 9, name: usr.right_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 16, name: usr.left_branch.left_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 17, name: usr.left_branch.right_branch.username, gambling: true, used_by_player: false, is_leaf: true
        # user_with_gambling_children
        usr = user_with_gambling_children
        expect(gambtree).to include lvl: 4, posn: 5, name: usr.username, gambling: false, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 10, name: usr.left_branch.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 11, name: usr.right_branch.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 6, posn: 20, name: usr.left_branch.left_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 21, name: usr.left_branch.right_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 22, name: usr.right_branch.left_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 23, name: usr.right_branch.right_branch.username, gambling: true, used_by_player: false, is_leaf: true
        # gambling_user_with_gambling_children
        usr = gambling_user_with_gambling_children
        expect(gambtree).to include lvl: 4, posn: 6, name: usr.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 12, name: usr.left_branch.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 5, posn: 13, name: usr.right_branch.username, gambling: true, used_by_player: false, is_leaf: false
        expect(gambtree).to include lvl: 6, posn: 24, name: usr.left_branch.left_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 25, name: usr.left_branch.right_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 26, name: usr.right_branch.left_branch.username, gambling: true, used_by_player: false, is_leaf: true
        expect(gambtree).to include lvl: 6, posn: 27, name: usr.right_branch.right_branch.username, gambling: true, used_by_player: false, is_leaf: true
        # no_gambler
        expect(gambtree).to include lvl: 4, posn: 7, name: no_gambler.username, gambling: false, used_by_player: false, is_leaf: true
      end
    end
  end
  
  describe '.add_leaf' do
    context "adds the new leaf as the left branch if it is nil" do
      it do
        usr = no_gambler
        new_leaf = FactoryGirl.create(:user, parent: usr)
        usr.add_leaf new_leaf
        expect(usr.left_branch).to eq new_leaf
      end
    end
    
    context "adds the new leaf as the right branch if it is nil and the left is not" do
      it do
        usr = gambling_user_no_right
        new_leaf = FactoryGirl.create(:user, parent: usr)
        usr.add_leaf new_leaf
        expect(usr.right_branch).to eq new_leaf
      end
    end 
    
    context "adds the new leaf to the left branch if it has less leaves than the right branch" do
      it do
        usr = gambling_user_unbalanced_left
        new_leaf = FactoryGirl.create(:user, parent: usr)
        usr.add_leaf new_leaf
        expect(usr.left_branch.left_branch).to eq new_leaf
      end
    end
    
    context "adds the new leaf to the left branch if it has the same amount of leaves than the right branch" do
      it do
        usr = gambling_user_one_level
        new_leaf = FactoryGirl.create(:user, parent: usr)
        usr.add_leaf new_leaf
        expect(usr.left_branch.left_branch).to eq new_leaf
      end
    end
    
    context "adds the new leaf to the right branch if it has less leaves than the left branch" do
      it do
        usr = gambling_user_unbalanced_right
        new_leaf = FactoryGirl.create(:user, parent: usr)
        usr.add_leaf new_leaf
        expect(usr.right_branch.left_branch).to eq new_leaf
      end
    end
  end
  
  describe '#validation' do
    context "user created successfully" do
      it{expect(new_user).to be_valid}
      
      context "has 15 seeds by default when created" do
        it{expect(new_user.seeds).to be 15}
      end
      
      context "saves last time user was awarded a seed" do
        it{expect(new_user.last_gambseed_gift_date).to be <= Time.current}
      end
      
      context "user puts no recommender" do
        context "sets user as the trunk if first user" do
          it{expect(root_user.is_trunk).to be true}
          it{expect(new_user.is_trunk).to be false}
        end
        
        context "user doesn't have a request" do
          it{expect(new_user.sent_request).to be_nil}
        end
        
        context "puts the user in left branch if both branches nil" do
          it{expect(left_branch).to eq root_user.left_branch}
        end
        
        context "puts the user in right branch if only right nil" do
          it{expect(right_branch).to eq root_user.right_branch}
        end
        
        def smallest_branch
          smallest_branch = root_user
          while child = smallest_branch.smaller_branch
            smallest_branch = child
          end
          return smallest_branch 
        end
        
        context "puts the user in the smaller branch of the trunk" do
          it do
            new_parent = smallest_branch
            expect(new_user.parent).to eq new_parent
          end
        end
      end
      
      context "user puts a recommender" do
        context "doesn't insert the user if it has a recommender" do
          it{expect(recommended_user.parent).to be_nil}
        end
        
        context "creates a request if the user has a recommender" do
          it{expect(recommended_user.sent_request).to_not be_nil}
          it{expect(recommended_user.sent_request.resolved).to be false}
          it{expect(recommended_user.sent_request).to eq recommender.received_requests.last}
        end
      end
      
    end
    
    context "is invalid without a full name" do
      let(:invalid_user) {FactoryGirl.build(:no_full_name_user)}
      it{expect(invalid_user).to be_invalid}
    end
    
    context "is invalid without a birth date" do
      let(:invalid_user) {FactoryGirl.build(:no_birth_date_user)}
      it{expect(invalid_user).to be_invalid}
    end
    
    context "is invalid without a username" do
      let(:invalid_user) {FactoryGirl.build(:no_username_user)}
      it{expect(invalid_user).to be_invalid}
    end
    
    context "is invalid without an email" do
      let(:invalid_user) {FactoryGirl.build(:no_email_user)}
      it{expect(invalid_user).to be_invalid}
    end
    
    context "is invalid without a password" do
      let(:invalid_user) {FactoryGirl.build(:no_password_user)}
      it{expect(invalid_user).to be_invalid}
    end
  end
  
  describe '.trunk' do 
    context "returns nil if no trunk" do
      it do
        User.delete_all 
        expect(User.trunk).to be_nil
      end
    end
    
    context "returns the first user that has the trunk attibute" do
      it{expect(User.trunk.is_trunk).to be true}
    end
  end
  
  describe '.gamble' do 
    context "returns nil if no gamble" do
      it{expect(new_user.gamble).to be nil}
    end
    
    context "returns nil if no gamble in current gambgame" do
      it{expect(old_gamble.user.gamble).to be_nil}
    end
    
    context "returns gamble of player in current gambgame" do
      it{expect(gamble.user.gamble).to_not be_nil}
    end
  end
  
  # pending_requests tests
  describe '.pending_requests' do
    context "returns no requests if the user has no requests" do
      it{expect(new_user.pending_requests).to be_empty}
    end
    
    context "returns no requests if the user only has accepted requests" do
      it{expect(recommender_no_pending.pending_requests).to be_empty}
    end
    
    context "returns the requests that the user has not accepted" do
      it{expect(recommender.pending_requests.length).to eq 1}
    end
  end
  
end
