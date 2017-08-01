class BillplzRenewal < ApplicationRecord
  def self.create_bill_for(userid)

    user = User.find(userid)
    package = user.package

    price = case package
      when 1 then 15000
      when 2 then 25000
      else 25000
    end

    url_bill_point = ENV['BILLPLZ_API'] + "/bills"

    HTTParty.post(url_bill_point.to_str,
    headers: {'Content-Type' => 'application/json','Accept '=> 'application/json' },
    body: {
      collection_id:      ENV["BILLPLZ_RENEWAL"],
      email:              user.email,
      name:               user.name,
      amount:             price,
      due_at:             Time.now + 2.days,
      callback_url:       ENV['URL'] + "/webhooks/renewal_callback",
      description:        'Ezicargo Renewal Payment',
      redirect_url:       ENV['URL'],
      deliver:            'false',
      reference_1_label:  'Ezicargo ID',
      reference_1:        user.ezi_id,
      reference_2_label:  'Package',
      reference_2:        package.to_s + " year(s)"

    }.to_json,
    basic_auth: { username: ENV["BILLPLZ_KEY"]}
    )
  end

  def self.check_status(bill_id)
    url = ENV['BILLPLZ_API'] + "/bills/" + bill_id
    arguments = { headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'},
                  basic_auth: { username: ENV["BILLPLZ_KEY"]}
                  }
    HTTParty.get(url, arguments)
  end
end
