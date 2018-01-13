require 'json'
require 'httparty'

module Onewaysms
  class Smser
    @base_url = ""
    @api_username = ""
    @api_password = ""
    def initialize(api_username, api_password)
      @api_username = api_username
      @api_password = api_password
      @base_url = "http://gateway.onewaysms.com.my:10001/"
    end

    def process_sms(mobile, senderid, message)
      response = HTTParty.get("#{@base_url}api.aspx/?apiusername=#{@api_username}&apipassword=#{@api_password}&mobileno=#{mobile}&senderid=#{senderid}&languagetype=1&message=#{message}")
      puts response.code
      puts response.body
    end

    # send noti parcel arrived
    def parcel_sms(mobile, awb)
      mobile = mobile.to_s
      message = "RM0.00 [ezicargo] your parcel with awb " + awb + "has arrived. Pls create shipment asap to avoid storage charges after 15 days"
      senderid = "ezi-parcel"
      return self.process_sms(mobile, senderid, message)
    end

  end
end
