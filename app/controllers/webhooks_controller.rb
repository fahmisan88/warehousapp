class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def payment_callback
    @shipment = Shipment.find_by(bill_id: params[:id])
    response = Billplz.check_status(@shipment.id)
    if (response['paid'] == true) && (response['state']=='paid')
      @shipment.update_attributes(status: 2, paid_at: params[:paid_at])
      @shipment.ordered_parcels.each do |x|
        x.parcel.update_attribute(:status, :Shipped)
    end
      render body: nil
  end
end
