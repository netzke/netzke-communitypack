class ComponentsController < ApplicationController
	def show
		@component = params[:component]
	end
end
