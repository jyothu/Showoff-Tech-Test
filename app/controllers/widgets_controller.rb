class WidgetsController < ApplicationController
  def index
    visible_widgets = api_client.visible_widgets(search_term: params[:q])
    @widgets = visible_widgets.dig('data', 'widgets')
  end

  def all
  	user_widgets = api_client.user_widgets(search_term: params[:q])
    @widgets = user_widgets.dig('data', 'widgets')
  end

  def create
  	api_client.create_widget(widget_params)
  	redirect_to users_me_widgets_path, success: 'Widget created successfully!'
  rescue => e
    @error = e.message
  end

  def destroy
  	api_client.delete_widget(params[:id])
  	redirect_to users_me_widgets_path, success: 'Widget deleted successfully!'
  rescue => e
    redirect_to users_me_widgets_path, danger: e.message
  end

  private

  def permitted_params
    params.permit(:name, :description, :kind).to_h
  end

  def widget_params
    { widget: permitted_params }
  end
end
