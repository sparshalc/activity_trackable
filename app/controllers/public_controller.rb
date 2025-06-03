class PublicController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    redirect_to dashboard_path if user_signed_in?
  end
end
