def consolidate_cart(items)
  cart = Hash.new
  items.each {|item_hash|
    item_hash.each {|item_property, value|
      cart[item_property] ||= value
      cart[item_property][:count] ||= 0
      cart[item_property][:count] += 1
    }
  }
  cart
end

def apply_coupons(cart, coupon_hash)
  final_hash = Hash.new
  cart.map {|item, item_properties|
    final_hash[item] = item_properties
    coupon_hash.each {|coupon|
      if coupon[:item] == item && cart[item][:count] >= coupon[:num]
        final_hash["#{item} W/COUPON"] = { :price => coupon[:cost], :clearance => cart[item][:clearance], :count => cart[item][:count]/coupon[:num] }
        final_hash[item][:count] = cart[item][:count]%coupon[:num]
      end
    }
  }
  final_hash
end

def apply_clearance(cart)
  cart.map do |item, item_attributes|
    if cart[item][:clearance] == true
      cart[item][:price] = (cart[item][:price]*0.8).round(2)
    end
  end
  cart
end

def checkout(cart, coupons)
  new_cart = consolidate_cart(cart)
  new_cart = apply_coupons(new_cart, coupons)
  new_cart = apply_clearance(new_cart)
  new_cart_total = new_cart.collect { |key, value| value[:price] * value[:count] }.inject() { |sum, n| sum + n }.round(2)
  if new_cart_total > 100.00
    new_cart_total = new_cart_total * 0.90
  end
  new_cart_total
end
