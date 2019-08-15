class ArticlesController < ApplicationController
  def index
    @arcticles = Articles::Article.all
  end

  def create
    article = Articles::Article.new(articles_params)
    article.save

    redirect_to action: :index
  end

  def show
    render plain: Articles::Article.find(params[:id]).html
  end

  private

  def articles_params
    params.require(:articles_article).permit(:url)
  end
end
