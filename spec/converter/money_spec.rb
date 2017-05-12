require 'spec_helper'

RSpec.describe Converter::Money do
  before(:each) do
    Converter::Money.class_variable_set :@@base_currency, nil
    Converter::Money.class_variable_set :@@rates, {}
  end

  describe 'initialize' do
    it 'raise error without params' do
      expect { Converter::Money.new }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 2)')
    end

    it 'raise error without number' do
      expect { Converter::Money.new('1', 'EUR') }.to raise_error(ArgumentError, 'currency rate is not a Number')
    end

    it 'raise error without currency' do
      expect { Converter::Money.new(1, :usd) }.to raise_error(ArgumentError, 'currency name is not a String')
    end

    it 'creates money object' do
      expect(Converter::Money.new(1, 'EUR').class).to eq(Converter::Money)
    end
  end

  describe 'amount' do
    let(:amount) { 13.33 }
    let(:money) { Converter::Money.new(amount, 'EUR')}

    it 'returns correct result type' do
      expect(money.amount).to be_a(Numeric)
    end

    it 'returns correct result' do
      expect(money.amount).to eq(amount)
    end
  end

  describe 'currency' do
    let(:currency) { 'EUR' }
    let(:money) { Converter::Money.new(13.3, currency)}

    it 'returns correct result type' do
      expect(money.currency).to be_a(String)
    end

    it 'returns correct result' do
      expect(money.currency).to eq(currency)
    end
  end

  describe 'inspect' do
    let(:money) { Converter::Money.new(13.3, 'EUR')}

    it 'returns correct result type' do
      expect(money.inspect).to be_a(String)
    end
    it 'returns correct result' do
      expect(money.inspect).to eq('13.30 EUR')
    end
  end

  %w(/ *).each do |method|
    describe method.to_s do
      let(:money) { Converter::Money.new(5, 'EUR')}

      it 'raise error with incorrect parameter' do
        expect { money.send(method, '2') }.to raise_error(ArgumentError, 'can\'t operate with not a Number')
      end

      it 'returns correct result type' do
        expect(money.send(method, 2)).to be_a(Converter::Money)
      end

      it 'returns correct amount' do
        expect((money.send(method, 2)).amount).to eq(money.amount.send(method, 2.0))
      end

      it 'returns correct currency' do
        expect((money.send(method, 2)).currency).to eq('EUR')
      end
    end
  end

  %w(+ -).each do |method|
    describe method.to_s do
      let(:money) { Converter::Money.new(500, 'EUR')}
      let(:bitcoin_rate) { 0.005 }

      before do
        Converter::Money.conversion_rates('EUR', { 'Bitcoin' => bitcoin_rate })
      end

      context 'same currency' do
        let(:money_2) { Converter::Money.new(3, 'EUR')}

        it 'raise error with incorrect parameter' do
          expect { money.send(method, '2') }.to raise_error(ArgumentError, 'must be instance of Converter::Money')
        end

        it 'returns correct result type' do
          expect(money.send(method, money_2)).to be_a(Converter::Money)
        end

        it 'returns correct amount' do
          expect((money.send(method, money_2)).amount).to eq(money.amount.send(method, money_2.amount))
        end

        it 'returns correct currency' do
          expect((money.send(method, money_2)).currency).to eq('EUR')
        end
      end

      context 'different currency' do
        let(:bitcoin_amount) { 3 }
        let(:money_2) { Converter::Money.new(bitcoin_amount, 'Bitcoin')}

        it 'returns correct result type' do
          expect(money.send(method, money_2)).to be_a(Converter::Money)
        end

        it 'returns correct amount' do
          bitcoin_in_eur = bitcoin_amount / bitcoin_rate.to_f
          expect((money.send(method, money_2)).amount).to eq(money.amount.send(method, bitcoin_in_eur))
        end

        it 'returns correct currency' do
          expect((money.send(method, money_2)).currency).to eq('EUR')
        end
      end
    end
  end

  %w(< >).each do |method|
    describe method.to_s do
      let(:money) { Converter::Money.new(500, 'EUR')}
      let(:bitcoin_rate) { 0.005 }

      before do
        Converter::Money.conversion_rates('EUR', { 'Bitcoin' => bitcoin_rate })
      end

      context 'same currency' do
        let(:money_2) { Converter::Money.new(300, 'EUR')}

        it 'raise error with incorrect parameter' do
          expect { money.send(method, '2') }.to raise_error(ArgumentError, 'must be instance of Converter::Money')
        end

        it 'returns correct result type' do
          expect(money.send(method, money_2)).to be_a(TrueClass).or be_a(FalseClass)
        end

        it 'returns correct result' do
          expect((money.send(method, money_2))).to eq(money.amount.send(method, money_2.amount))
        end
      end

      context 'different currency' do
        let(:bitcoin_amount) { 100 }
        let(:money_2) { Converter::Money.new(bitcoin_amount, 'Bitcoin')}

        it 'returns correct result type' do
          expect(money.send(method, money_2)).to be_a(TrueClass).or be_a(FalseClass)
        end

        it 'returns correct result' do
          bitcoin_in_eur = bitcoin_amount / bitcoin_rate.to_f
          expect((money.send(method, money_2))).to eq(money.amount.send(method, bitcoin_in_eur))
        end
      end
    end
  end

  describe '==' do
    let(:money) { Converter::Money.new(500, 'EUR')}

    before do
      Converter::Money.conversion_rates('EUR', { 'Bitcoin' => 0.005 })
    end

    context 'same currency' do
      let(:money_2) { Converter::Money.new(500, 'EUR')}

      it 'raise error with incorrect parameter' do
        expect(money == '2').to eq(false)
      end

      it 'returns correct result type' do
        expect(money == money_2).to be_a(TrueClass).or be_a(FalseClass)
      end

      it 'returns correct result when equal' do
        expect(money == money_2).to eq(true)
      end

      it 'returns correct result when not equal' do
        expect(money == Converter::Money.new(501, 'EUR')).to eq(false)
      end
    end

    context 'different currency' do
      it 'returns correct result when equal' do
        expect(money == Converter::Money.new(2.5, 'Bitcoin')).to eq(true)
      end

      it 'returns correct result when not equal' do
        expect(money == Converter::Money.new(2.6, 'Bitcoin')).to eq(false)
      end
    end
  end

  describe 'conversion_rates' do
    it 'requires first argument as a string' do
      expect { Converter::Money.conversion_rates(:eur, { 'Bitcoin' => 0.005 }) }.to raise_error(ArgumentError, 'base currency key is not a String')
      expect(Converter::Money.class_variable_get(:@@rates)).to eq({})
    end

    it 'requires second argument as a hash' do
      expect { Converter::Money.conversion_rates('EUR', []) }.to raise_error(ArgumentError, 'base currency rates is not a Hash')
      expect(Converter::Money.class_variable_get(:@@rates)).to eq({})
    end

    it 'requires currencies as a string' do
      expect { Converter::Money.conversion_rates('EUR', { Bitcoin: 0.005 }) }.to raise_error(ArgumentError, 'currency key is not a String')
      expect(Converter::Money.class_variable_get(:@@rates)).to eq({})
    end

    it 'requires rate to be numeric' do
      expect { Converter::Money.conversion_rates('EUR', { 'Bitcoin' => '0.005' }) }.to raise_error(ArgumentError, 'currency \'Bitcoin\' rate is not a Number')
      expect(Converter::Money.class_variable_get(:@@rates)).to eq({})
    end

    it 'assigns correct base currency' do
      Converter::Money.conversion_rates('EUR', { 'Bitcoin' => 0.005 })
      expect(Converter::Money.class_variable_get(:@@base_currency)).to eq('eur')
    end

    it 'assigns correct currencies rates' do
      Converter::Money.conversion_rates('EUR', { 'Bitcoin' => 0.005 })
      expect(Converter::Money.class_variable_get(:@@rates)).to eq('bitcoin' => 0.005, 'eur' => 1)
    end

    it 'returns true on success' do
      expect(Converter::Money.conversion_rates('EUR', {})).to eq(true)
    end
  end

  describe 'convert_amount' do
    let(:money) {Converter::Money.new(0, 'EUR')}
    it 'raise error when first rate is missing' do
      expect { money.send(:convert_amount, 10, 'EUR', 'USD') }.to raise_error(ArgumentError, 'undefined currency rate')
    end

    it 'raise error when second rate is missing' do
      Converter::Money.class_variable_set(:@@rates, { 'usd' => 1.2})
      expect { money.send(:convert_amount, 10, 'USD', 'EUR') }.to raise_error(ArgumentError, 'undefined currency rate')
    end

    it 'converts when rates present' do
      Converter::Money.class_variable_set(:@@rates, { 'usd' => 1.2, 'eur' => 1})
      expect(money.send(:convert_amount, 6, 'USD', 'EUR')).to eq(5)
    end
  end
end
