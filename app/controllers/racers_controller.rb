class RacersController < ApplicationController

  before_action :find_racer, only: %w[show update destroy]

  def index
    @racers = Racer.page(params[:page]).per(10)
    @racer = Racer.new
  end

  def new
    @racer = Racer.new
  end

  def create
    @racer = Racer.new(racer_params)
    ActiveRecord::Base.transaction do
      @racer.collect
      @racer.save! if @racer.valid?
    end
    redirect_to @racer
  end

  def show; end

  def collect
    ActiveRecord::Base.transaction do
      (2014..5094).to_a.each do |int|
        racer_number = sprintf('%04d', int)
        @racer = Racer.find_by(racer_number: racer_number) || Racer.new(racer_number: racer_number)
        @racer.collect
        @racer.save! if @racer.valid?
        Mikazuki.rand_sleep(40)
      end
    end
    redirect_to :index
  end

  def update
    ActiveRecord::Base.transaction do
      @racer.collect
      @racer.save! if @racer.valid?
    end
    redirect_to @racer
  end

  def destroy
    ActiveRecord::Base.transaction do
      @racer.destroy!
    end
    redirect_to :index
  end

  private

  def find_racer
    @racer = Racer.find_by(params[:id])
  end

  def racer_params
    params.require(:racer).permit(:racer_number)
  end
end
