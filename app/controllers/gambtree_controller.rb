class GambtreeController < ApplicationController
  before_action :authenticate_user!
  
  def pending_requests
    @gambtree = current_user.gambtree
  end
  
  def add_leaf_to_branch
    request = JoinRequest.find(params[:request_id])
    if request && !request.resolved && request.user.parent.nil? && current_user = request.receiver
      leaf = request.user
      branch = params[:to_left] == "true" ? current_user.left_branch : current_user.right_branch
      if branch.nil?
        if params[:to_left] == "true"
          current_user.left_branch = leaf
        else
          current_user.right_branch = leaf
        end
        leaf.parent = current_user
        leaf.save
        current_user.save
      else
        branch.insert_leaf leaf
      end
      request.resolved = true
      request.save
      flash[:sucess] = "Leaf successfully added."
    else
      flash[:error] = "Request does not exist."
    end
    redirect_to gambtree_pending_requests_path
  end
  
end
