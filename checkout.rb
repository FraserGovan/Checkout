#!/usr/bin/env ruby

class Item
  attr_reader :code
  attr_reader :description
  attr_accessor :price
  def initialize(code, description, price)
    @code = code
    @description = description
    @price = price
  end
end

class Inventory
  attr_reader :items
  def initialize
    @items = []
    @items.push(Item.new("GR1", "Green Tea", 3.11))
    @items.push(Item.new("SR1", "Strawberries", 5.00))
    @items.push(Item.new("CF1", "Coffee", 11.23))
  end
end

class PriceRule
  attr_reader :items
  attr_reader :iQuant
  attr_reader :discounts
  attr_reader :dQuant
  
  def initialize(desc, items, iQuant, discounts, dQuant)
    @desc = desc #description of offer
    @items = items #item codes
    @iQuant = iQuant #quantities of each item
    @discounts = discounts #item codes
    @dQuant = dQuant #quantities of each discount
  end
  
  def applies(rule, basket)
    catch :ruleFailed do
      rule.items.each_with_index { |code, index| #iterate over each item in rule
        # = = =
        searchIndex = basket.items.index(code)
        if searchIndex == nil
          throw :ruleFailed
        end
        string = rule.iQuant[index].split(":")
        case string[1]
        when ""
          case string[0]
          when ""
            unless basket.quantities[searchIndex] >= string[2].to_i            
              throw :ruleFailed
            end
          when ">"
            unless basket.quantities[searchIndex] > string[2].to_i            
              throw :ruleFailed
            end
          when ">="
            unless basket.quantities[searchIndex] >= string[2].to_i
              throw :ruleFailed
            end
          when "<"
            unless basket.quantities[searchIndex] < string[2].to_i               
              throw :ruleFailed
            end
          when "<="
            unless basket.quantities[searchIndex] <= string[2].to_i               
              throw :ruleFailed
            end
          when "=="
            unless basket.quantities[searchIndex] == string[2].to_i              
              throw :ruleFailed
            end
          end
        when "£"
        case string[0]
          when ""
            unless basket.total >= string[2].to_i            
              throw :ruleFailed
            end
          when ">"
            unless basket.total > string[2].to_i            
              throw :ruleFailed
            end
          when ">="
            unless basket.total >= string[2].to_i
              throw :ruleFailed
            end
          when "<"
            unless basket.total < string[2].to_i               
              throw :ruleFailed
            end
          when "<="
            unless basket.total <= string[2].to_i               
              throw :ruleFailed
            end
          when "=="
            unless basket.total == string[2].to_i              
              throw :ruleFailed
            end
          end
        end
      true
      }
    end
  end
end

class PricingRules
  attr_reader :rules
  def initialize
    @rules = []    
  end
  
  def add_rule(rule)
    @rules.push(rule)
  end
end

class Basket
  attr_reader :items
  attr_reader :quantities
  attr_accessor :total
  
  def initialize(inventory)
    @inv = inventory
    @items = []
    @quantities = []
    @total = 0
  end
  
  def add_item(code, quantity)
    index = @items.index(code)
    if index
      @quantities[index] += quantity
    else
      @items.push(code)
      @quantities.push(quantity)
    end
  end
  
  def remove_item(code, quantity)
    index = @items.index(code)
    if index
      if @quantities[index] > quantity
        @quantities[index] -= quantity
      else
        @items.delete_at(index)
        @quantities.delete_at(index)
      end
    end
  end
  
  def total
    items.each_with_index { |code, index|
      quantity = @quantities[index]
      invIndex = @inv.items.index { |i| i.code == code }
      price = @inv.items[invIndex].price
      @total += price*quantity      
    }
    @total
  end
end

class Checkout
  def initialize(pricing_rules)
    @inv = Inventory.new 
    @pRules = pricing_rules
    @bskt = Basket.new(@inv)
  end

  def scan(code)  #scan an item into the basket
    @bskt.add_item(code, 1)
  end
  
  def list  #print out a list of items and quantities
    @bskt.items.each_with_index { |code, index|
      product = @inv.items.find {|i| i.code == code}
      puts "#{product.description} : 
      #{@bskt.quantities[index]}"}
  end
  
  def total
  @total = 0
    @totalBskt = Basket.new(@inv)
    #apply discounts and move items to total basket
    @pRules.rules.each do |rule|  #iterate over each price rule
      catch :ruleFailed do
        #check if rule can be applied
        unless rule.applies(rule, @bskt)
          throw :ruleFailed
        end
        #move items to total basket
        rule.items.each_with_index { |code, index| #iterate over each item in rule
          if (code.is_a? String) && (rule.iQuant[index].is_a? Numeric)
            @totalBskt.add_item(code, rule.iQuant[index])
             product = @inv.items.find { |product| product.code == code }
            @total += product.price*rule.iQuant[index]
            @bskt.remove_item(code, rule.iQuant[index])
          elsif (code.is_a? String) && (rule.iQuant[index].is_a? String)
            string = rule.iQuant[index].split(":")
            if string[0] == ""
              
            end
            searchIndex = @bskt.items.index(code)
            quantity = @bskt.quantities[index]
            @totalBskt.add_item(code, quantity)
            product = @inv.items.find { |product| product.code == code }
            @total += product.price*quantity
            @bskt.remove_item(code, quantity)
          elsif (code.is_a? Numeric) && (rule.iQuant[index].is_a? Numeric)
          
          elsif (code.is_a? Numeric) && (rule.iQuant[index].is_a? String)
          
          end
        }
        #apply discounts
        rule.discounts.each_with_index { |discount, index|
          if (rule.discounts[index].is_a? String) && (rule.dQuant[index].is_a? Numeric)
            product = @inv.items.find { |product| product.code == discount }
            @total -= product.price*rule.dQuant[index]
          elsif (rule.discounts[index].is_a? String) && (rule.dQuant[index].is_a? String)            
            searchIndex = @totalBskt.items.index(rule.dQuant[index])
            quantity = @totalBskt.quantities[searchIndex]
            product = @inv.items.find { |product| product.code == discount }
            @total -= product.price*quantity
          elsif (rule.discounts[index].is_a? Numeric) && (rule.dQuant[index].is_a? Numeric)
            @total -= rule.discounts[index]*rule.dQuant[index]
          elsif (rule.discounts[index].is_a? Numeric) && (rule.dQuant[index].is_a? String)
            searchIndex = @totalBskt.items.index(rule.dQuant[index])
            quantity = @totalBskt.quantities[searchIndex]
            @total -= rule.discounts[index]*quantity
          end
        }
        redo
      end        
    end
    #add remaining items to total basket
    @bskt.items.each_with_index { |code, index|
      quantity = @bskt.quantities[index]
      @totalBskt.add_item(code, quantity)
      product = @inv.items.find { |product| product.code == code }
      @total += product.price*quantity }
    
    @bskt.items.clear
    @bskt.quantities.clear
    @bskt.total = 0
    puts @total
    @totalBskt.items.clear
    @totalBskt.quantities.clear
    @totalBskt.total = 0
    @total = 0
  end  
end

pricing_rules = PricingRules.new
pricing_rules.add_rule(PriceRule.new("2 for 1 on Green Tea!", ["GR1"], ["::2"], ["GR1"], [1]))
pricing_rules.add_rule(PriceRule.new("Discount when buying 3 or more Strawberrys!", ["SR1"], [">=::3"], [0.50], ["SR1"]))

co = Checkout.new(pricing_rules)

#=begin
co.scan("GR1")
co.scan("SR1")
co.scan("GR1")
co.scan("GR1")
co.scan("CF1")
co.total
#=end

#=begin
co.scan("GR1")
co.scan("GR1")
co.total
#=end

#=begin
co.scan("SR1")
co.scan("SR1")
co.scan("GR1")
co.scan("SR1")
co.total
#=end
