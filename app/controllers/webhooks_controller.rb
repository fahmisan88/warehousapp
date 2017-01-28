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
          x.parcel.update_attribute(:status, "Shipped")
        end
      render body: nil
    end
  end

#fungsi untuk replace ezi_id dalam string eg. Q0500 kepada integer dengan buang Q kat depan untuk calculate tambah 1 bagi increment of ezi_id dan concantenate dgn string Q semula.
  def user_payment_callback
    @user = User.find_by(bill_id: params[:id])
    @last_ezi = User.all.where.not(:ezi_id => nil).order(:ezi_id).last.ezi_id.gsub(/[^0-9]/, '').to_i
    @ezi_id = @last_ezi + 1
    @ezi_id_string = "Q" + @ezi_id.to_s.rjust(4,'0')
    @expiry = @user.package * 365
    response = BillplzReg.check_status(@user.id)
    if (response['paid'] == true) && (response['state']=='paid')
        @user.update_attributes(status: 1, :ezi_id => @ezi_id_string, :expiry => @expiry.days.from_now)
      render body: nil
    end
  end
end
