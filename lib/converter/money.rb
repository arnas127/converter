module Converter
  class Money
    @@rates = {}

    def initialize(amount, currency)
      raise ArgumentError, 'currency rate is not a Number' unless amount.is_a? Numeric
      raise ArgumentError, 'currency name is not a String' unless currency.is_a? String
      @amount = amount
      @currency = currency
    end

    def self.conversion_rates(currency, rates = {})
      raise ArgumentError, 'base currency key is not a String' unless currency.is_a? String
      raise ArgumentError, 'base currency rates is not a Hash' unless rates.is_a? Hash
      @@rates = {}

      rates.each do |key, value|
        unless key.is_a? String
          @@rates = {}
          raise ArgumentError, 'currency key is not a String'
        end

        unless value.is_a? Numeric
          @@rates = {}
          raise ArgumentError, "currency '#{key}' rate is not a Number"
        end

        @@rates[key.downcase] = value
      end

      @@base_currency = currency.downcase
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
        raise ArgumentError, 'can\'t operate with not a Number' unless number.is_a? Numeric
        calculated_amount = @amount.to_f.send(method_name, number)
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

    %w(< >).each do |method_name|
      define_method(method_name) do |money|
        money?(money)
        new_amount = convert_amount(money.amount, money.currency, @currency)
        @amount.send(method_name, new_amount)
      end
    end

    def ==(money)
        return false unless money.is_a?(self.class)
        new_amount = convert_amount(money.amount, money.currency, @currency)
        @amount.round(2) == new_amount.round(2)
    end

    private

    def convert_amount(amount, old_currency, new_currency)
      if @@rates.has_key?(new_currency.downcase) && @@rates.has_key?(old_currency.downcase)
        amount.fdiv(@@rates[old_currency.downcase]) * @@rates[new_currency.downcase]
      else
        raise ArgumentError, 'undefined currency rate'
      end
    end

    def money?(money)
      raise ArgumentError, "must be instance of #{self.class}" unless money.is_a?(self.class)
    end
  end
end
