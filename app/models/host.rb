class Host < ActiveRecord::Base
  has_many :matches
  has_many :patterns, through: :matches
end
