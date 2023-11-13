class Image < ApplicationRecord

    has_one_attached :image

    validate :validate_image_format, :validate_image_size

    private

    def validate_image_format
        return unless image.attached? && !image.content_type.in?(%w[image/jpeg image/png])
        errors.add(:image, 'must be a JPEF or PNG')
    end


    def validate_image_size

        return unless image.attached? && image.byte_size > 5.megabytes
        errors.add(:image, 'size must be less than 5MB')
    end
end