require 'spec_helper'

describe Customer do
  before do
    client
  end

  let(:username) { ENV['SSTK_USERNAME'] || 'testuser' }
  subject(:customer) { Customer.find(username: username) }

  it 'should return a customer for a username' do
    expect(customer.account_id).to be > 0
    expect(customer.username).to eq username
  end

  it 'should return customers lightboxes' do
    lightboxes = customer.lightboxes
    expect(lightboxes).to be_kind_of Array
    expect(lightboxes[0]).to be_kind_of Lightbox
    expect(lightboxes[0].images).to be_kind_of Images
    expect(lightboxes[0].images[0]).to be_kind_of Image
  end

  it "should get customer's downloads" do
    expect(customer.downloads).to be_kind_of Hash
  end
end
