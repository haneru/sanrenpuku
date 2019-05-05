class ResultsController < ApplicationController

  before_action :find_source, only: %w[show update destroy]

  def index
    @results = Result.page(params[:page]).per(10)
  end

  def new
    @result = Result.new
  end

  def create
    @result = Result.new(result_params)
    return render :new if result_params[:collect_date] == ''
    collect_fields
  end

  def result
    @result = Result.new(result_params)

    unless @result.valid?
      collect_fields
      return render :create
    end

    @result.collect_race_win_per

    if @result.valid?
      ActiveRecord::Base.transaction do
        @result.save!
      end
      redirect_to @result
    else
      render :create
    end
  end

  def show
    redirect_to root_url if @result.blank?
  end

  def update
    @result.collect_race_win_per
    ActiveRecord::Base.transaction do
      @result.save!
    end
    redirect_to @result
  end

  def destroy
    ActiveRecord::Base.transaction do
      @result.destroy!
    end
    redirect_to root_url
  end

  private

  def find_source
    @result = Result.find_by(id: params[:id])
  end

  def result_params
    params.require(:result)
          .permit(
            :collect_date,
            :race_number,
            :field_id
          )
  end

  def collect_fields
    uri = "https://www.boatrace.jp/owpc/pc/race/index?hd=#{result_params[:collect_date].to_time.strftime('%Y%m%d')}"
    @page = Mikazuki.get_page(uri)
    field_names = @page.css('body')
                       .css('tbody')
                       .css('td.is-arrow1.is-fBold.is-fs15')
                       .map(&:children)
                       .map(&:children)
                       .map(&:to_a)
                       .map(&:first)
                       .map(&:attributes)
                       .map { |td| td['alt'].text.gsub(/\>/, '') }
    @fields = Field.where(name: field_names)
  end
end
