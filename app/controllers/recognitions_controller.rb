class RecognitionsController < ApplicationController
  before_action -> { authorize :recognition, policy_class: RecognitionPolicy }, only: %i[index show new create]
  before_action :set_recognition, only: [ :show ]
  before_action :set_users_and_categories, only: %i[index new create]

  def index
    @recognitions = filter_recognitions
    @pagy, @recognitions = pagy(@recognitions, items: 10)

    respond_to do |format|
      format.html
      format.json { render json: { recognitions: @recognitions, users: @users, categories: @categories } }
    end
  end

  def show
  end

  def new
    @recognition = Recognition.new
  end

  def create
    @recognition = Recognition.new(recognition_params)
    @recognition.giver = current_user
    @recognition.company = ActsAsTenant.current_tenant

    if @recognition.save
      redirect_to recognitions_path, notice: "Recognition was successfully given! 🎉"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_users_and_categories
    @users = policy_scope(User)
             .joins(:company_users)
             .where(company_users: { company_id: ActsAsTenant.current_tenant.id })
             .select(:id, :full_name, :email)
             .order(:full_name)

    # For new and create actions, exclude current user (can't give recognition to themselves)
    if %w[new create].include?(action_name)
      @users = @users.where.not(id: current_user.id)
    end

    @categories = Recognition::CATEGORIES
  end

  def set_recognition
    @recognition = policy_scope(Recognition).find(params[:id])
  end

  def recognition_params
    params.require(:recognition).permit(:recipient_id, :category, :points, :message)
  end

  def filter_recognitions
    recognitions = policy_scope(Recognition).includes(:giver, :recipient).recent

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
