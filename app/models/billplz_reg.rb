class BillplzReg
  def self.create_bill_for(user)
    user = user

    package = user.package
    
    price = case package
      when 1 then 15000
      when 2 then 25000
      when 3 then 30000
      else 30000
    end

    HTTParty.post("https://www.billplz.com/api/v3/bills/".to_str,
    headers: {'Content-Type' => 'application/json','Accept '=> 'application/json' },
    body: {
      collection_id:      ENV["BILLPLZ_REG_APPID"],
      email:              user.email,
      name:               user.name,
      amount:             price,
      callback_url:       ENV['URL'] + "/webhooks/user_payment_callback",
      description:        'Ezicargo Registration',
      redirect_url:       ENV['URL'] + "/users/#{user.id}/pay",
      deliver:            'true',
      reference_1_label:  'User ID',
      reference_1:        user.id,

    }.to_json,
    basic_auth: { username: ENV["BILLPLZ_KEY"]}
    )
  end

  def self.check_status(user_id)
    user = User.find(user_id)
    url = "https://www.billplz.com/api/v3/bills/" + user.bill_id
    arguments = { headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'},
                  basic_auth: { username: ENV["BILLPLZ_REG_KEY"]}
                  }
    HTTParty.get(url, arguments)
  end
end