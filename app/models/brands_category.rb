class BrandsCategory < ApplicationRecord
  belongs_to :category
  belongs_to :brand
end
