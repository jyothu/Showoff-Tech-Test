class WidgetsController < ApplicationController
  def index
    visible_widgets = api_client.visible_widgets(search_term: params[:q])
    @widgets = visible_widgets['data']['widgets']

    respond_to do |format|
      format.js
      format.html
    end
  end
end
