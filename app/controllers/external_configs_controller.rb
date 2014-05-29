class ExternalConfigsController < ApplicationController
  before_filter :check_admin_user

  def index
    @external_config = ExternalConfig.new
    @external_configs = ExternalConfig.all
  end

  def create
    @external_config = ExternalConfig.new(params[:external_config])
    if params[:external_config][:config_type] == 'lti'
      generate_lti_keys(@external_config)
    end
    if @external_config.save
      flash[:notice] = "Successfully created ExternalConfig."
      redirect_to external_configs_path
    else
      @external_configs = ExternalConfig.all
      render :action => 'index'
    end
  end

  def edit
    @external_config = ExternalConfig.find(params[:id])
  end

  def update
    @external_config = ExternalConfig.find(params[:id])
    if @external_config.update_attributes(params[:external_config])
      flash[:notice] = "Successfully updated ExternalConfig."
      redirect_to external_configs_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @external_config = ExternalConfig.find(params[:id])
    @external_config.destroy
    flash[:notice] = "Successfully destroyed ExternalConfig."
    redirect_to external_configs_path
  end

  def generate_lti_keys(conf)
    conf.value = Digest::MD5.hexdigest(Time.now.to_i.to_s + rand.to_s).to_s
    conf.shared_secret = Digest::MD5.hexdigest(Time.now.to_i.to_s + rand.to_s + conf.value)
    conf
  end

end
