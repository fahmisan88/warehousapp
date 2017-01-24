class BillplzReg
  def self.create_bill_for(user)
    user = user
    HTTParty.post("https://www.billplz.com/api/v3/bills/".to_str,
    headers: {'Content-Type' => 'application/json','Accept '=> 'application/json' },
    body: {
      collection_id:      ENV["BILLPLZ_REG_APPID"],
      email:              user.email,
      name:               user.name,
      amount:             15000,
      callback_url:       ENV['URL'] + "/sessions/new",
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