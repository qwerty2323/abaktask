class PagesController < ApplicationController
  
  # GET /
  def index
    @tree = Page.tree

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pages }
    end
  end

  # GET /:path
  def show
    
    @page = Page.find_by_path(params[:path])

    @tree = @page.tree if @page

    respond_to do |format|
      if @page
        format.html 
      else
        format.html { redirect_to root_path, notice: 'Page not found!' }
      end
    end
  end

  # GET /:path/add
  def new
  
    @parent_path = '/'+params[:path].to_s
    
    @parent = Page.find_by_path(params[:path])

    @tree = @parent.tree  if @parent      

    @page = Page.new

    #@page.parent= Page.find_by_path(parent_path) if parent_path

    respond_to do |format|
      if @parent.nil? and @parent_path != '/'
        format.html { redirect_to root_path, notice: 'Cannot find parent page!' }
      else
        format.html # new.html.erb
      end
    end
  end

  # GET /:path/edit
  def edit
    @page = Page.find_by_path(params[:path])
    @tree = @page.tree if @page

    unless @page
      redirect_to root_path, notice: 'Page not found!'
    end
  end

  # POST /:path
  def create
    parent_page = Page.find_by_path(params[:path].to_s)
    
    @page = Page.new(params[:page])

    #@page.parent= Page.find_by_path(@parent_path) if @parent_path

    respond_to do |format|
      if @page.save
        @page.parent!(parent_page) if parent_page
        format.html { redirect_to @page.url, notice: 'Page was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /:path
  def update
    @page = Page.find_by_path(params[:path])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to @page.url, notice: 'Page was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

end
