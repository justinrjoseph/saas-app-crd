class Artifact < ActiveRecord::Base
  before_save :upload_to_s3
  attr_accessor :upload
  belongs_to :project
  
  MAX_FILE_SIZE = 10.megabytes
  validates :name, presence: :true, uniqueness: :true
  validates :upload, presence: :true
  
  validate :uploaded_file_size
  
  private
  
    def upload_to_s3
      s3 = Aws::S3::Resource.new
      tenant_name = Tenant.find(Thread.current[:tenant_id]).name
      obj = s3.bucket(ENV['S3_BUCKET']).object("#{tenant_name}/#{upload.original_filename}")
      obj.upload_file(upload.path, acl: 'public-read')
      self.key = obj.public_url
    end
  
    def uploaded_file_size
      if upload
        errors.add(:upload, "File size must be less than #{MAX_FILE_SIZE}.") unless upload.size < MAX_FILE_SIZE
      end
    end
end
