class FieldsController < ApplicationController
  def index
    @fields = Field.page(params[:page])
                   .per(6)
                   .order(:code)

  end

  def new
    @field = Field.new
  end

  def create
    @field = Field.new(field_params)
    if @field.valid?
      ActiveRecord::Base.transaction do
        @field.save!
        redirect_to fields_url
      end
    else
      return render :new
    end
  end

  def show
    @field = Field.find_by(id: params[:id])
  end

  def edit
    @field = Field.find_by(id: params[:id])
  end

  def update
    @field = Filed.find_by(id: params[:id])
  end

  def destroy
    @field = Filed.find_by(id: params[:id])
    ActiveRecord::Base.transaction do
      @field.destroy!
    end
    redirect_to fields_url
  end

  private

  def field_params
    params.require(:field).permit(:name, :code)
  end
end
