# -*- encoding : utf-8 -*-
class City < ActiveRecord::Base
  belongs_to :province
  has_many :towns

end
