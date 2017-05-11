module Converter
  class Money
    def initialize(amount, currency)
      raise ArgumentError, "currency rate is not a number" unless amount.is_a? Numeric
      raise ArgumentError, "currency name is nor a string" unless currency.is_a? String
      @amount = amount
      @currency = currency
    end

    def self.conversion_rates(currency, rates = {})
      @@rates = {}
      rates.each do |key, value|
        unless value.is_a? Numeric
          @@rates = {}
          raise ArgumentError, "currency '#{key}' rate is not a number"
        end
        @@rates[key.to_s.downcase] = value
      end

      @@base_currency = currency.to_s.downcase
      @@rates[@@base_currency] = 1
      true
    end

    def amount
      @amount
    end

    def currency
      @currency
    end

    def inspect
      '%.2f ' %  @amount + @currency
    end

    def convert_to(new_currency)
      new_amount = convert_amount(@amount, @currency, new_currency)
      self.class.new(new_amount, new_currency)
    end

    %w(/ *).each do |method_name|
      define_method(method_name) do |number|
        raise ArgumentError, "can't operate with not a number" unless number.is_a? Numeric
        calculated_amount = @amount.send(method_name, number)
        self.class.new(calculated_amount, @currency)
      end
    end

    %w(+ -).each do |method_name|
      define_method(method_name) do |money|
        money?(money)
        new_amount = convert_amount(money.amount, money.currency, @currency)
        calculated_amount = @amount.send(method_name, new_amount)
        self.class.new(calculated_amount, @currency)
      end
    end

    %w(== < >).each do |method_name|
      define_method(method_name) do |money|
        money?(money)
        new_amount = convert_amount(money.amount, money.currency, @currency)
        @amount.round(2).send(method_name, new_amount.round(2))
      end
    end

    private

    def convert_amount(amount, old_currency, new_currency)
      if defined?(@@rates) && @@rates.has_key?(new_currency.downcase) && @@rates.has_key?(old_currency.downcase)
        amount.fdiv(@@rates[old_currency.downcase]) * @@rates[new_currency.downcase]
      else
        raise ArgumentError, 'undefined currency rate'
      end
    end

    def money?(money)
        puts '-'*50
        puts money
        puts money.class
      raise ArgumentError, "must be instance of #{self.class}" unless money.is_a?(self.class)
    end
  end
end
