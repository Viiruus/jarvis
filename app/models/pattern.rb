class Pattern < ActiveRecord::Base
  has_many :matches
  has_many :hosts, through: :matches
end
