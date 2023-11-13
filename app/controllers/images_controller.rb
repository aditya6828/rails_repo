class ImagesController < ApplicationController
    def new
      @image = Image.new
    end
  
    def create
      @image = Image.new(image_params)
  
      if @image.save
        flash[:notice] = 'Image uploaded successfully!'
        redirect_to root_path
      else
        flash[:error] = 'Error uploading image'
        render :new
      end
    end
  
    private
  
    def image_params
      params.require(:image).permit(:image)
    end
  end
  