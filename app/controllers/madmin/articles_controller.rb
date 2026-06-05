module Madmin
  class ArticlesController < Madmin::ResourceController
    def create
      @record = resource.model.new(resource_params)
      @record.user_id = Current.user.id
      if @record.save
        redirect_to resource.show_path(@record)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
end
