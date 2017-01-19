class Billplz
  def self.create_bill_for(shipment)
    shipment = shipment
    HTTParty.post("https://www.billplz.com/api/v3/bills/".to_str,
    headers: {'Content-Type' => 'application/json','Accept '=> 'application/json' },
    body: {
      collection_id:      ENV["BILLPLZ_APPID"],
      email:              shipment.user.email,
      name:               shipment.user.name,
      amount:             shipment.charge*100,
      callback_url:       "http://localhost:3000/webhooks/payment_callback",
      description:        'Ezicargo Shipping Fee',
      due_at:             shipment.due_at,
      redirect_url:       "http://localhost:3000/shipments/#{shipment.id}",
      deliver:            'true',
      reference_1_label:  'Shipment ID',
      reference_1:        shipment.id,
      reference_2_label:  'Final Weight/Volume',
      reference_2:
      if shipment.weight > shipment.volume
      "#{shipment.weight}kg"
      else
       "#{shipment.volume}kg"
      end
    }.to_json,
    basic_auth: { username: ENV["BILLPLZ_KEY"]}
    )
  end

  def self.check_status(shipment_id)
    shipment = shipment.find(shipment_id)
    url = "https://www.billplz.com/api/v3/bills/" + shipment.bill_id
    arguments = { headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'},
                  basic_auth: { username: ENV["BILLPLZ_KEY"]}
                  }
    HTTParty.get(url, arguments)
  end
end
