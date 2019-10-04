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
    
    setState = false
    
    @all_ratings = Movie.get_all_ratings
    
    @sort_by = params[:sort_field]
    
    if @sort_by
      session[:sort_field] = @sort_by
    elsif session[:sort_field]
      @sort_by=session[:sort_field]
      setState = true
    end
    
    if params[:commit] =='Refresh' and params[:ratings].nil?
      @set_ratings = nil
      session[:ratings] = nil
    elsif params[:ratings]
      @set_ratings = params[:ratings]
      session[:ratings] = @set_ratings
    elsif session[:ratings]
      @set_ratings = session[:ratings]
      setState = true
    else
      @set_ratings = nil
    end
    
    if setState
      flash.keep
      puts(@set_ratings)
      redirect_to(:action=>'index',:sort_field=>@sort_by,:ratings=>@set_ratings)
    end
    
    if @set_ratings and @sort_by
      @movies = Movie.where(:rating=>@set_ratings.keys).order(@sort_by)
    elsif @set_ratings
      @movies = Movie.where(:rating=>params[:ratings].keys)
    elsif @sort_by
      @movies = Movie.all.order(params[:sort_field])
    else
      @movies = Movie.all
    end
    if !@set_ratings
      @set_ratings = Hash.new(@all_ratings)
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
