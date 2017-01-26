class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def payment_callback
    @shipment = Shipment.find_by(bill_id: params[:id])
    response = Billplz.check_status(@shipment.id)
    if (response['paid'] == true) && (response['state']=='paid')
        @shipment_user = @shipment.user_id
        @user_info = User.find(@shipment_user)
        deliver_mail(@user_info.name, @user_info.email, "shipments", "readytoship")

        @shipment.update_attributes(status: "Shipped", paid_at: params[:paid_at])
        @shipment.ordered_parcels.each do |x|
          x.parcel.update_attribute(:status => :"Shipped")
        end
      render body: nil
    end
  end

  def user_payment_callback
    @user = User.find_by(bill_id: params[:id])
    @ezi_id = @user.ezi_id + @user.id + 399
    response = BillplzReg.check_status(@user.id)
    if (response['paid'] == true) && (response['state']=='paid')
        @user.update_attribute(:status, 1)
        @user.update_attribute(:ezi_id, @ezi_id)
      render body: nil
    end
  end
end
