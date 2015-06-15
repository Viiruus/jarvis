class Match < ActiveRecord::Base
  belongs_to :host
  belongs_to :pattern
end
