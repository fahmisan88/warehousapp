module ShipmentsHelper

def calculate_kg(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb
  charge = 0

  chargeByWeight0To3 = (shipment.final_kg * 30 ) / ringgit
  chargeByWeight3To10 = (shipment.final_kg * 26 ) / ringgit
  chargeByWeight10above = (shipment.final_kg * 23 ) / ringgit
  chargeByWeight31To60 = (shipment.final_kg * 22 ) / ringgit
  chargeByWeight61To100 = (shipment.final_kg * 21 ) / ringgit
  chargeByWeight101above = (shipment.final_kg * 20 ) / ringgit

  chargeByWeight0To11ToSS = (shipment.final_kg * 41 ) / ringgit
  chargeByWeight11aboveToSS = (shipment.final_kg * 38 ) / ringgit
  chargeByWeight31To60ToSS = (shipment.final_kg * 37 ) / ringgit
  chargeByWeight61To100ToSS = (shipment.final_kg * 36 ) / ringgit
  chargeByWeight101aboveToSS = (shipment.final_kg * 35 ) / ringgit

  sensitiveChargeByWeight0To2 = (shipment.final_kg * 56) / ringgit
  sensitiveChargeByWeight2To3 = (shipment.final_kg * 44 ) / ringgit
  sensitiveChargeByWeight3To4 = (shipment.final_kg * 36 ) / ringgit
  sensitiveChargeByWeight4To5 = (shipment.final_kg * 34  ) / ringgit
  sensitiveChargeByWeight5To7 = (shipment.final_kg * 32 ) / ringgit
  sensitiveChargeByWeight7To9 = (shipment.final_kg * 31 ) / ringgit
  sensitiveChargeByWeight9To11 = (shipment.final_kg * 30  ) / ringgit
  sensitiveChargeByWeight11Above = (shipment.final_kg * 27 ) / ringgit
  sensitiveChargeByWeight31To60 = (shipment.final_kg * 26 ) / ringgit
  sensitiveChargeByWeight61To100 = (shipment.final_kg * 25 ) / ringgit
  sensitiveChargeByWeight101Above = (shipment.final_kg * 24 ) / ringgit

  sensitiveChargeByWeight0To2ToSS = (shipment.final_kg * 72 ) / ringgit
  sensitiveChargeByWeight2To3ToSS = (shipment.final_kg * 57  ) / ringgit
  sensitiveChargeByWeight3To4ToSS = (shipment.final_kg * 52 ) / ringgit
  sensitiveChargeByWeight4To5ToSS = (shipment.final_kg * 50 ) / ringgit
  sensitiveChargeByWeight5To6ToSS = (shipment.final_kg * 48 ) / ringgit
  sensitiveChargeByWeight6To8ToSS = (shipment.final_kg * 47  ) / ringgit
  sensitiveChargeByWeight8To10ToSS = (shipment.final_kg * 46 ) / ringgit
  sensitiveChargeByWeight10To11ToSS = (shipment.final_kg * 45 ) / ringgit
  sensitiveChargeByWeight11AboveToSS = (shipment.final_kg * 42 ) / ringgit
  sensitiveChargeByWeight31To60ToSS = (shipment.final_kg * 41) / ringgit
  sensitiveChargeByWeight61To100ToSS = (shipment.final_kg * 40  ) / ringgit
  sensitiveChargeByWeight101AboveToSS = (shipment.final_kg * 39  ) / ringgit

  if shipment.shipment_type == "Normal"
    if !shipment.is_borneo?
      if shipment.final_kg < 3
        charge =  chargeByWeight0To3.ceil(1)
      elsif shipment.final_kg >= 3 && shipment.final_kg < 11
        charge =  chargeByWeight3To10.ceil(1)
      elsif shipment.final_kg >= 11 && shipment.final_kg < 31
        charge =  chargeByWeight10above.ceil(1)
      elsif shipment.final_kg >= 31 && shipment.final_kg < 61
        charge =  chargeByWeight31To60.ceil(1)
      elsif shipment.final_kg >= 61 && shipment.final_kg < 101
        charge =  chargeByWeight61To100.ceil(1)
      elsif shipment.final_kg >= 101
        charge =  chargeByWeight101above.ceil(1)
      end
    else
      if shipment.final_kg < 11
        charge =  chargeByWeight0To11ToSS.ceil(1)
      elsif shipment.final_kg >= 11 && shipment.final_kg < 31
        charge =  chargeByWeight11aboveToSS.ceil(1)
      elsif shipment.final_kg >= 31 && shipment.final_kg < 61
        charge =  chargeByWeight31To60ToSS.ceil(1)
      elsif shipment.final_kg >= 61 && shipment.final_kg < 101
        charge =  chargeByWeight61To100ToSS.ceil(1)
      elsif shipment.final_kg >= 101
        charge =  chargeByWeight101aboveToSS.ceil(1)
      end
    end
  elsif shipment.shipment_type == "Sensitive" || shipment.shipment_type == "Sensitive magnet" || shipment.shipment_type == "Sensitive branded" || shipment.shipment_type == "Sensitive battery" || shipment.shipment_type == "Sensitive cosmetic"
    if !shipment.is_borneo?
      if shipment.final_kg < 2
        charge =  sensitiveChargeByWeight0To2.ceil(1)
      elsif shipment.final_kg >= 2 && shipment.final_kg < 3
        charge =  sensitiveChargeByWeight2To3.ceil(1)
      elsif shipment.final_kg >= 3 && shipment.final_kg < 4
        charge =  sensitiveChargeByWeight3To4.ceil(1)
      elsif shipment.final_kg >= 4 && shipment.final_kg < 5
        charge =  sensitiveChargeByWeight4To5.ceil(1)
      elsif shipment.final_kg >= 5 && shipment.final_kg < 7
        charge =  sensitiveChargeByWeight5To7.ceil(1)
      elsif shipment.final_kg >= 7 && shipment.final_kg < 9
        charge =  sensitiveChargeByWeight7To9.ceil(1)
      elsif shipment.final_kg >= 9 && shipment.final_kg < 11
        charge =  sensitiveChargeByWeight9To11.ceil(1)
      elsif shipment.final_kg >= 11 && shipment.final_kg < 31
        charge =  sensitiveChargeByWeight11Above.ceil(1)
      elsif shipment.final_kg >= 31 && shipment.final_kg < 61
        charge =  sensitiveChargeByWeight31To60.ceil(1)
      elsif shipment.final_kg >= 61 && shipment.final_kg < 101
        charge =  sensitiveChargeByWeight61To100.ceil(1)
      elsif shipment.final_kg >= 101
        charge =  sensitiveChargeByWeight101Above.ceil(1)
      end
    else
      if shipment.final_kg < 2
        charge =  sensitiveChargeByWeight0To2ToSS.ceil(1)
      elsif shipment.final_kg >= 2 && shipment.final_kg < 3
        charge =  sensitiveChargeByWeight2To3ToSS.ceil(1)
      elsif shipment.final_kg >= 3 && shipment.final_kg < 4
        charge =  sensitiveChargeByWeight3To4ToSS.ceil(1)
      elsif shipment.final_kg >= 4 && shipment.final_kg < 5
        charge =  sensitiveChargeByWeight4To5ToSS.ceil(1)
      elsif shipment.final_kg >= 5 && shipment.final_kg < 6
        charge =  sensitiveChargeByWeight5To6ToSS.ceil(1)
      elsif shipment.final_kg >= 6 && shipment.final_kg < 8
        charge =  sensitiveChargeByWeight6To8ToSS.ceil(1)
      elsif shipment.final_kg >= 8 && shipment.final_kg < 10
        charge =  sensitiveChargeByWeight8To10ToSS.ceil(1)
      elsif shipment.final_kg >= 10 && shipment.final_kg < 11
        charge =  sensitiveChargeByWeight10To11ToSS.ceil(1)
      elsif shipment.final_kg >= 11 && shipment.final_kg < 31
        charge =  sensitiveChargeByWeight11AboveToSS.ceil(1)
      elsif shipment.final_kg >= 31 && shipment.final_kg < 61
        charge =  sensitiveChargeByWeight31To60ToSS.ceil(1)
      elsif shipment.final_kg >= 61 && shipment.final_kg < 101
        charge =  sensitiveChargeByWeight61To100ToSS.ceil(1)
      elsif shipment.final_kg >= 101
        charge =  sensitiveChargeByWeight101AboveToSS.ceil(1)
      end
    end
  end
  return charge
end

def calculate_photoshoot(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb
  charge = 0

  chargePhotoshoot = shipment.parcels.where(photoshoot: true).size * 10

  charge = (chargePhotoshoot / ringgit).ceil(1)
  return charge
end

def calculate_inspection(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb
  charge = 0

  chargeInspection = shipment.parcels.where(inspection: true).size * 30

  charge = (chargeInspection / ringgit).ceil(1)
  return charge
end

def calculate_reorganize(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb
  charge = 0

  chargeReorganize = shipment.parcels.size * 2
  charge = (chargeReorganize / ringgit).ceil(1)
  return charge
end

def calculate_repackaging(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb
  charge = 0

  chargeRepackaging = 10
  charge = (chargeRepackaging / ringgit).ceil(1)
  return charge
end

def calculate_add_charge(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb

  charge = (shipment.extra_charge / ringgit).ceil(1)
  return charge
end

def calculate_minus_charge(shipment)
  shipment = Shipment.find(params[:id])
  currency = Currency.find_by(id: 1)
  ringgit = currency.myr2rmb

  charge = (shipment.minus_charge / ringgit).ceil(1)
  return charge
end

def calculate_storage(parcel)
  parcel = Parcel.find_by(id: parcel)
  currency = Currency.find_by(id: 1)
  days = ((Time.now - parcel.free_storage) / 3600 / 24).round
  ringgit = currency.myr2rmb

  charge = (days * 5 / ringgit).ceil(1)
  return charge
end

end
