class ExternalConfig < ActiveRecord::Base

   validates :config_type,:app_name ,:shared_secret,:value , presence: true

   belongs_to :organization


   def self.generate(name)
     conf = ExternalConfig.find_by_config_type_and_app_name('lti',name)
     unless conf
       conf = ExternalConfig.create(:config_type => 'lti', :app_name => name)
     end
     conf.value ||= Digest::MD5.hexdigest(Time.now.to_i.to_s + rand.to_s).to_s
     conf.shared_secret ||= Digest::MD5.hexdigest(Time.now.to_i.to_s + rand.to_s + conf.value)
     conf.save
     conf
   end

end
