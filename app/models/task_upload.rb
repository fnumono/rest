class TaskUpload < ActiveRecord::Base
	belongs_to :task

	has_attached_file :upload, :styles => lambda{ |a|
                                  ["image/jpeg", "image/png", "image/jpg", "image/gif"].include?( a.content_type ) ? {
                                  :thumb=> "26x44!",                                  
                                  :medium => "100x100>"}: {}
                                 }   , 
                            default_url: "/images/:style/missing.png"
  validates_attachment_content_type :upload , content_type: [/\Aimage\/.*\Z/, 'application/pdf', \
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document', \
            'application/vnd.openxmlformats-officedocument.presentationml.presentation', \
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', \
            'application/msword', 'application/vnd.ms-excel', 'text/plain', 'application/rtf']
	
  def attributes
  	a = super
  	a[:uploadThumbUrl] = nil
  	a[:uploadUrl] = nil  	
  	a
  end

  def uploadUrl  
  	Settings.host_url + upload.url if !upload.url.nil?
  end  

  def uploadThumbUrl  
    Settings.host_url + upload.url(:thumb) if !upload.url.nil?
  end


end
