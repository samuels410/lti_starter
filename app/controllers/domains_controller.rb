class DomainsController < ApplicationController
  before_filter :check_admin_user

  def index
    @domain = Domain.new
    @domains = Domain.all
  end

  def create
    @domain = Domain.new(params[:domain])
    if @domain.save
      flash[:notice] = "Successfully created Domain."
      redirect_to domains_path
    else
      @domains = Domain.all
      render :action => 'index'
    end
  end

  def edit
    @domain = Domain.find(params[:id])
  end

  def update
    @domain = Domain.find(params[:id])
    if @domain.update_attributes(params[:domain])
      flash[:notice] = "Successfully updated Domain."
      redirect_to domains_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    @domain.destroy
    flash[:notice] = "Successfully destroyed Domain."
    redirect_to domains_path
  end

end
