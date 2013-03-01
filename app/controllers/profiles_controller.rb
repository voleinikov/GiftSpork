class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_profile_exists, :only => [:show]
  
  def new
    @profile = current_user.build_profile()
  end

  def create
    @profile = current_user.build_profile(params[:profile])
    if @profile.save
      flash[:success] = "Profile created"
      redirect_to user_profile_path(current_user)
    else
      render 'new'
    end
  end

  def show
      @profile = Profile.find_by_user_id(params[:user_id])
  end

  def edit
    @profile = Profile.find_by_user_id(current_user.id)
  end

  # REV: if you're going
  def update
    @profile = Profile.find_by_user_id(current_user.id)
    if @profile.update_attributes(params[:profile])
      flash[:success] = "Profile updated"
      redirect_to user_profile_path(current_user)
    else 
      render 'edit'
    end
  end

  private

  # If a user creates an account and closes browser before
  # creating a profile, they need to create one before
  # they can use the service

  def check_profile_exists
    profile = Profile.find_by_user_id(current_user.id)

    # If profile is not found it will be set to nil and this will redirect to creating a profile
    unless profile 
      redirect_to new_user_profile_path()
    end
  end

end
