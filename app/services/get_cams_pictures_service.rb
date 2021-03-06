class GetCamsPicturesService
  def perform
    new_screenshots = []
    Camera.all.each do |camera|

      # all this should be an api call
      @cam = Cam.find_by(name: camera.streaming_url)
      unless @cam
        @cam = Cam.create(name: camera.streaming_url, last_shown: 0)
      end
      reinitialize_index if @cam.last_shown >= 46
      img_path = "lib/images/#{camera.streaming_url}/"
      img_filename = "img0#{(@cam.last_shown + 1).to_s.rjust(2, '0')}.jpg"
      @cam.last_shown += 1
      @cam.save
      # end of api call

      @sh = Screenshot.new(camera_id: camera.id)
      @sh.image.attach(io: File.open(Rails.root.join(img_path, img_filename)), filename: img_filename , content_type: "image/jpg")
      @sh.save
      set_status_from_watson
      check_for_alerts
      new_screenshots << @sh
    end
    new_screenshots
  end

  private

  def reinitialize_index
    @cam.last_shown = 0
    @cam.save
  end

  def set_status_from_watson
    watson_service = Watson.new
    result = watson_service.visual_recognition_image(@sh.image)
    result = (eval result)
    label = result[:images].first[:classifiers].first[:classes].max_by {|k, v| v }
    @sh.status = label[:class].downcase
    @sh.score = label[:score]
    @sh.save
  end

  def check_for_alerts
    if @sh.red?
      @sh.alerts.create(
        category: "Alerta roja (congestión)",
        description: "Congestión severa. Por favor dirija unidades móviles con caracter de urgencia",
        dismissed: false
      )
    elsif @sh.yellow?
      @sh.alerts.create(
        category: "Alerta Amarilla (precaución)",
        description: "Potencial congestión. Por favor dirija personal para ayudar al transito responsable de usuarios",
        dismissed: false
      )
    end
  end
end
