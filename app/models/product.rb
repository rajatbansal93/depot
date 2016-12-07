class Product < ActiveRecord::Base
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item
  validates :title, :description, :image_url, presence: true
  # validates :permalink, format: { with: /\A[^ ][a-zA-Z0-9\-]+\z/ }
  # validates :permalink, format: { with: /[^ ]/ }
  # validates_length_of :description, in: 5..10, tokenizer: ->(str) { str.scan(/\w+/) }
  validates :price, numericality: {greater_than_or_equal_to: 0.01}, if: :is_price_empty?
  # validates :title, :permalink, uniqueness: true
  # validates_length_of :permalink, minimum: 3, tokenizer: ->(str) { str.split('-') }
  validates :image_url, allow_blank: true, format: {
    with:
    %r{\.(gif|jpg|png)\Z}i,
    message: 'must be a URL for GIF, JPG or PNG image.'
  }
  validates_each :image_url do |record, attr, value|
    record.errors.add(attr, 'must end with .jpg') if
    value !~ /[.jpg]\z/
  end
  validates :price, numericality: {greater_than_or_equal_to: :discount_price}

  after_initialize do |product|
    product.title = 'abc' unless product.title
    product.discount_price = product.price unless product.discount_price
  end

  def self.latest
    Product.order(:updated_at).last
  end

  def is_price_empty?
    price == ""
  end

  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      return true
    else
      errors.add(:base, 'Line Items present')
      return false
    end
  end

end
