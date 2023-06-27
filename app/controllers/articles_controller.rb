class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    # Initializing the session[:page_views] to 0 if it doesn't exist
    session[:page_views] ||= 0

    # Incrementing the session[:page_views] by 1 for each request
    session[:page_views] += 1

    # Finding the requested article
    article = Article.find(params[:id])

    # If the user has viewed fewer than 3 pages, render a JSON response with the article data
    if session[:page_views] <= 3
      render json: article
    else
      # If the user has viewed 3 or more pages, render a JSON response with an error message and a status code of 401 unauthorized
      render json: { error: 'Paywall activated. Subscribe for unlimited access.' }, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end
