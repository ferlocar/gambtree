class GambtreeController < ApplicationController
  before_action :authenticate_user!
  
  def pending_requests
    @gambtree = get_gambtree current_user
  end
  
  def add_leaf_to_branch
    branch = params[:to_left] == "true" ? current_user.left_branch : current_user.right_branch
    request = JoinRequest.find(params[:request_id])
    unless request.nil? && !request.resolved && request.user.parent.nil?
      leaf = request.user
      branch.insert_leaf leaf
      request.resolved = true
      request.save
      flash[:sucess] = "Leaf successfully added."
    else
      flash[:error] = "Request does not exist."
    end
    redirect_to gambtree_pending_requests_path
  end
  
  protected
  
  def get_gambtree user
    gambtree = [{:lvl => 1, :posn => 0}] + get_leaves(user, 2, 0)
    puts gambtree.inspect 
    return gambtree
  end
  
  def get_leaves trunk, lvl, posn
    if trunk.left_branch.nil? && trunk.right_branch.nil?
      return []
    else
      branches = [trunk.left_branch, trunk.right_branch]
      leaves = []
      next_lvl_posn = posn * 2;
      is_left = true
      branches.each do |branch|
        if branch
          next_lvl_posn += 1 unless is_left
          leaves << {:lvl => lvl, :posn => next_lvl_posn}
          leaves += get_leaves(branch, lvl+1, next_lvl_posn)
        end
        is_left = false
      end
      return leaves
    end
  end
  
end
