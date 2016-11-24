class OrderedParcel < ApplicationRecord
  belongs_to :parcel
  belongs_to :shipment
end
