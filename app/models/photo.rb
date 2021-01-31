class Photo < ApplicationRecord
  belongs_to :post

  validates :image, :presence => true

  mount_uploader :image, PhotoUploader

  class << self
    # アップロードされた画像のサイズをバリデーションする
    def picture_size?(image)
      image.size < 1.megabytes
    end
  end
end
