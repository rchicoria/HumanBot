require 'net/http'
require 'rexml/document'

class PhotosController < ApplicationController
  def create
    @photo = Photo.new(params[:photo])
    @photo.image = File.new(upload_path)
    @photo.save

    redirect_to @photo
  end

  def show
    @photo = Photo.find(params[:id])
    photo = "#{Rails.root}/public/uploads/foto.jpg"
    url = "http://api.face.com/faces/detect.xml?api_key=e8b9c37170fb2b4a310e399d4bc03daf&api_secret=47a3d44bc3c1950de135cd1a8c9f4938&urls=#{photo}"
    puts url
    xml_data = Net::HTTP.get_response(URI.parse(url)).body

    # extract event information
    doc = REXML::Document.new(xml_data)

    gender = 'male'

    background = '15'
    eyes='12'
    mouth='49'
    legs = '06'
    head = '07'

    male_smiling_mouth = '09'
    female_smiling_mouth = '47'
    glasses_eyes = '08'

    doc.elements.each('response/photos/photo/tags/tag/attributes/gender/value') do |gender|
      gender = gender.text
      background = '02' if gender == 'female'
      legs = '01' if gender == 'female'
      head = '38' if gender == 'female'
    end

    doc.elements.each('response/photos/photo/tags/tag/attributes/glasses/value') do |glasses|
      eyes = '08' if glasses.text == 'true'
    end

    doc.elements.each('response/photos/photo/tags/tag/attributes/smiling/value') do |smiling|
       
      if smiling.text == 'true'
        mouth = male_smiling_mouth if gender == 'male'
        mouth = female_smiling_mouth if gender == 'female'
      end
    end

    puts "https://services.sapo.pt/Codebits/botmake/01,#{background},03,#{eyes},#{mouth},#{legs},#{head},00,Generated!"
  end

  def index
    @photos = Photo.all
  end

  def upload
    File.open(upload_path, 'w') do |f|
      f.write request.raw_post
    end
    render :text => "ok"
  end

  private

  def upload_path # is used in upload and create
#    file_name = session[:session_id].to_s + '.jpg'
#    File.join(Rails.root, 'public', 'uploads', file_name)
     "#{Rails.root}/public/uploads/foto.jpg"
  end
end
