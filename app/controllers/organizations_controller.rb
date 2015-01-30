class OrganizationsController < ApplicationController
  before_filter :check_admin_user

  def index
    @organization = Organization.new
    @organizations = Organization.all
  end

  def create
    @organization = Organization.new(permitted_params)
    if @organization.save
      flash[:notice] = "Successfully created Organization."
        redirect_to organizations_path
    else
      @organizations = Organization.all
      render :action => 'index'
    end
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(permitted_params)
      flash[:notice] = "Successfully updated Organization."
      redirect_to organizations_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy
    flash[:notice] = "Successfully destroyed Organization."
    redirect_to organizations_path
  end

  private

  def permitted_params
    params.require(:organization).permit(:host, :name,:url,:image,:email)
  end

end
