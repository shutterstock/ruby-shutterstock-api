require 'spec_helper'

describe Client do

  context "#initialize" do
    it "should require a block" do
			expect { Client.instance.configure }.to raise_error(ArgumentError)
    end
  end

  context 'basic auth' do
    it 'should raise an exception when api_username is not provided' do
      expect do
				Client.instance.configure do |config|
          config.api_key = "12345"
          config.api_url = "http://api.shutterstock.com"
        end
      end.to raise_error(ArgumentError)
    end

    it 'should raise an exception when api_key is not provided' do
      expect do
				Client.instance.configure do |config|
          config.api_username = "testuser"
          config.api_url = "http://api.shutterstock.com"
        end
      end.to raise_error(ArgumentError)
    end
  end

  context 'auth token' do

    api_username = ENV['SSTK_API_USERNAME'] || 'basicauthusername'
    api_key  = ENV['SSTK_API_KEY'] || 'basicauthapikey'
    api_url  = 'http://api.shutterstock.com'
    username = ENV['SSTK_USERNAME'] || 'testuser'
    password = ENV['SSTK_PASSWORD'] || '12345'

    it 'should raise error for invalid customer credentials' do
      expect do
				Client.instance.configure do |config|
          config.api_username = api_username
          config.api_key = api_key
          config.api_url = api_url
          config.username = username
          config.password = 'p@ss'
        end
      end.to raise_error(RuntimeError)
    end

    context 'valid customer credentials' do
      test_user = 'testuser'
      subject do
        client
      end

      it 'should retrieve auth token' do
        subject.config.auth_token.should_not be_nil
        expect(subject.options[:base_uri]).to eql(api_url)
        expect(subject.options[:basic_auth]).to eql(
          username: api_username,
          password: api_key
        )
        (subject.options[:default_params][:auth_token]).should match(/\w+/)
      end
    end
  end

  context '#method_missing' do

    let(:username) { 'testuser' }
    let(:lightbox_id) { 21_722_255 }
    let(:image_id) { 118_139_110 }
    subject(:customer) { Customer.find(client,  username: username) }

    it '.customers.find' do
      user = client.customers.find(username: username)
      expect(user.username).to eql(username)
    end

    it '.lightboxes.find' do
      lightbox = client.lightboxes.find(id: lightbox_id)
      expect(lightbox).to be_instance_of(Lightbox)
    end

    it '.images.find' do
      image = client.images.find(id: image_id)
      expect(image).to be_instance_of(Image)
    end
  end
end
