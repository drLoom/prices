class EstateController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        @estates = Estate.filter
        render json: @estates.to_json
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: Estate.history(params[:id].to_i).to_json
      end
    end
  end
end
