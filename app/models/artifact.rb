class Artifact < ActiveRecord::Base
  attr_accessor :upload
  belongs_to :project
  
  MAX_FILE_SIZE = 10.megabytes
  validates :name, presence: :true, uniqueness: :true
  validates :upload, presence: :true
  
  validate :uploaded_file_size
  
  private
  
    def uploaded_file_size
      if upload
        errors.add(:upload, "File size must be less than #{MAX_FILE_SIZE}.") unless upload.size < MAX_FILE_SIZE
      end
    end
end
