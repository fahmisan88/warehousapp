class Billplz
  def self.create_bill_for(shipment)
    shipment = shipment
    HTTParty.post((ENV['BILLPLZ_API'] + "/bills/").to_str,
    headers: {'Content-Type' => 'application/json','Accept '=> 'application/json' },
    body: {
      collection_id:      ENV["BILLPLZ_APPID"],
      email:              shipment.user.email,
      name:               shipment.user.name,
      amount:             shipment.charge*100,
      callback_url:       ENV['URL'] + "/webhooks/payment_callback",
      description:        'Ezicargo Shipping Fee',
      due_at:             shipment.due_at,
      redirect_url:       ENV['URL'] + "/shipments/#{shipment.id}",
      deliver:            'true',
      reference_1_label:  'Shipment ID',
      reference_1:        shipment.id,
      reference_2_label:  'Final Weight/Volume',
      reference_2:        "#{shipment.final_kg}kg"
    }.to_json,
    basic_auth: { username: ENV["BILLPLZ_KEY"]}
    )
  end

  def self.check_status(shipment_id)
    shipment = Shipment.find(shipment_id)
    url = ENV['BILLPLZ_API'] + "/bills/" + shipment.bill_id
    arguments = { headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'},
                  basic_auth: { username: ENV["BILLPLZ_KEY"]}
                  }
    HTTParty.get(url, arguments)
  end
end
