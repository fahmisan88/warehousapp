class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

# to update parcel has_many through association before destroy shipment
  private
  def update_status
    self.ordered_parcels.each do |x|
      x.parcel.update_attribute(:status, :Arrived)
    end
  end
end
