class BillplzReg
  def self.create_bill_for(user)
    user = user
    HTTParty.post("https://www.billplz.com/api/v3/bills/".to_str,
    headers: {'Content-Type' => 'application/json','Accept '=> 'application/json' },
    body: {
      collection_id:      ENV["BILLPLZ_REG_APPID"],
      email:              user.email,
      name:               user.name,
      amount:             100,
      callback_url:       "http://localhost:3000/webhooks/user_payment_callback",
      description:        'Ezicargo Registration',
      redirect_url:       "http://localhost:3000/users/#{user.id}/pay",
      deliver:            'true',
      reference_1_label:  'User ID',
      reference_1:        user.id,

    }.to_json,
    basic_auth: { username: ENV["BILLPLZ_KEY"]}
    )
  end

  def self.check_status(user_id)
    user = user.find(user_id)
    url = "https://www.billplz.com/api/v3/bills/" + user.bill_id
    arguments = { headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'},
                  basic_auth: { username: ENV["BILLPLZ_REG_KEY"]}
                  }
    HTTParty.get(url, arguments)
  end
end
