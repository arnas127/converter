require 'spec_helper'

RSpec.describe Converter do
  it 'has a version number' do
    expect(Converter::VERSION).not_to be nil
  end

  it 'has defined Money class' do
    expect(defined?(Converter::Money)).to eq('constant')
  end
end
