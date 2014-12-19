class EnrollmentsController < ApplicationController

before_filter :check_for_session

def check_for_session
  @per_page ||= 100

  if !session['domain_id'] || !session['user_id'] || !session['source_id']
    render 'session_lost'
  else
    @user_config = UserConfig.find_by_user_id_and_domain_id(session['user_id'], session['domain_id'])
  end
end

def activate_users
  params[:page] = '1' if params[:page].to_i == 0

  if @user_config
    @enrollments = api_call("/api/v1/courses/#{session["launch_course_id"]}/enrollments/?type[]=StudentEnrollment&per_page=#{@per_page}&page=#{params[:page].to_i}", @user_config)
  end

end




end
