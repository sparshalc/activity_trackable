class RecognitionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recognition, only: [ :show ]

  def index
    @recognitions = filter_recognitions
    @pagy, @recognitions = pagy(@recognitions, items: 10)
    @users = ActsAsTenant.current_tenant.users.select(:id, :full_name, :email).order(:full_name)
    @categories = Recognition::CATEGORIES
  end

  def show
  end

  def new
    @recognition = Recognition.new
    @users = ActsAsTenant.current_tenant.users.where.not(id: current_user.id).order(:full_name)
    @categories = Recognition::CATEGORIES
  end

  def create
    @recognition = Recognition.new(recognition_params)
    @recognition.giver = current_user
    @recognition.company = ActsAsTenant.current_tenant

    if @recognition.save
      redirect_to recognitions_path, notice: "Recognition was successfully given! 🎉"
    else
      @users = ActsAsTenant.current_tenant.users.where.not(id: current_user.id).order(:full_name)
      @categories = Recognition::CATEGORIES
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_recognition
    @recognition = Recognition.find(params[:id])
  end

  def recognition_params
    params.require(:recognition).permit(:recipient_id, :category, :points, :message)
  end

  def filter_recognitions
    recognitions = Recognition.includes(:giver, :recipient).recent

    # Filter by date range
    if params[:date_range].present?
      case params[:date_range]
      when "today"
        recognitions = recognitions.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
      when "week"
        recognitions = recognitions.where(created_at: 1.week.ago..Time.current)
      when "month"
        recognitions = recognitions.where(created_at: 1.month.ago..Time.current)
      end
    end

    # Filter by recipient
    if params[:recipient_id].present?
      recognitions = recognitions.for_recipient(params[:recipient_id])
    end

    # Filter by giver
    if params[:giver_id].present?
      recognitions = recognitions.for_giver(params[:giver_id])
    end

    # Filter by category
    if params[:category].present?
      recognitions = recognitions.where(category: params[:category])
    end

    recognitions
  end
end
