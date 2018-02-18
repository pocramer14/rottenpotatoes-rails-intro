class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #create a ratings variable for storing ratings options
    @all_ratings = ['G','PG','PG-13','R']
    #if user has clicked on a parameter (title, release date, etc.), then sort by that parameter
    if(!(session[:session_key].nil?) && (!(params[:key] == 'title') || !(params[:key] == 'release_date')))
      if session[:session_key] == 'title'
        @title_css = 'hilite'
        @movies = Movie.order(title: :asc)
      elsif session[:session_key] == 'release_date'
        @release_css = 'hilite'
        @movies = Movie.order(release_date: :asc)
      end
    elsif params[:key] == 'title'
      session[:session_key] = 'title'
      @title_css = 'hilite'
      @movies = Movie.order(title: :asc)
    elsif params[:key] == 'release_date'
      session[:session_key] = 'release_date'
      @release_css = 'hilite'
      @movies = Movie.order(release_date: :asc)
    else
      @movies = Movie.all
      #check if we need to filter by rating
      if(params[:ratings].nil? && session[:session_ratings].nil?) #if nothing has been selected, do not filter
        @movies = Movie.all
      elsif(!(params[:ratings].nil?)) #else, filter, selecting only movies with the selected ratings
        @rating_filter =params[:ratings].keys
        session[:session_ratings] = params[:ratings].keys
        @movies = Movie.where(rating: @rating_filter)
      else
        @rating_filter = session[:session_ratings]
        @movies = Movie.where(rating: @rating_filter)
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
