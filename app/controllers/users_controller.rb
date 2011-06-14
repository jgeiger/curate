class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:show]

  def show
    @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to(root_path, error: 'That user does not exist.')
  end

end
