class Api::V1::ImagesController < ApplicationController

    before_action :find_image, only: [:update]
     def index
       @images = Image.all
       render json: @images
     end

     def update
       @image.update(image_params)
       if @image.save
         render json: @image, status: :accepted
       else
         render json: { errors: @image.errors.full_messages }, status: :unprocessible_entity
       end
     end

     def create
       @image =  Image.create(image_params)
       @image.picture.attach(params[:picture])
        details = []
         Dotenv.load
         client = Aws::Rekognition::Client.new
         resp = client.detect_labels( image:{ bytes: @image.picture.download  })
         resp.labels.each {|label|  details  << "#{label.name}-#{label.confidence.to_i}"}
      @image.update(url: url_for(@image.picture), details: details)
      render json: @image
     end

     def show
       @image = Image.find(params[:id])
       render json: @image
     end


     private

     def image_params
       params.permit(:name, :user_id, :picture, :details)
     end

     def find_image
       @image = Image.find(params[:id])
     end

end
