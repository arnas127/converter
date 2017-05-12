require 'spec_helper'

RSpec.describe CurrencyManager do
  it 'has a version number' do
    expect(CurrencyManager::VERSION).not_to be nil
  end

  it 'has defined Money class' do
    expect(defined?(CurrencyManager::Money)).to eq('constant')
  end
end
