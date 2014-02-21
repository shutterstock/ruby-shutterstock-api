require 'spec_helper'

describe Configuration do
  subject { Configuration.new }

  it 'should return api_url when set' do
    subject.api_url = 'http://api.shutterstock.com'
    expect(subject.api_url).to eql('http://api.shutterstock.com')
  end
end
