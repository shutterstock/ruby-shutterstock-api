require 'spec_helper'

describe Lightbox do
  context 'find' do
    let(:id) { 21_722_255 }
    let(:image_id) { 96_815_971 }
    subject(:lightbox) { Lightbox.find(id: id) }

    it 'should find a lightbox, given an id' do
      client # setup the client using 'client' method in spec_helper
      expect(Lightbox).to respond_to(:find)

      expect(lightbox).to_not be_nil
      expect(lightbox.confirmed?).to be_true
      expect(lightbox.resource_url).to match id.to_s
      expect(lightbox.id).to eql id
      expect(lightbox.name.size).to be > 2
    end

    it 'should convert list to images' do
      expect(lightbox.images).to be_kind_of Images
      expect(lightbox.images[0]).to be_kind_of Image
    end

    it 'should raise error for invalid lightbox id' do
      mocked_auth

      test_id = 12_345_678
      resp_double = double(code: 403, body: 'Not allowed to access lightbox')
      req_opts = client.options

      Lightbox.should_receive(:get).with("/lightboxes/#{test_id}/extended.json", req_opts).and_return(resp_double)
      expect { Lightbox.find(id: test_id) }.to raise_error(RuntimeError)
    end

    it 'should be able to add an image' do
      client # setup the client using 'client' method in spec_helper
      Lightbox.any_instance.should_receive(:add_image).with(image_id: image_id)
      expect { lightbox.add_image(image_id: image_id) }.not_to raise_error
    end

    it 'should be able to remove an image' do
      client # setup the client using 'client' method in spec_helper
      Lightbox.any_instance.should_receive(:remove_image).with(image_id: image_id)
      expect { lightbox.remove_image(image_id: image_id) }.not_to raise_error
    end
  end

  context do
    before do
      mocked_auth
    end

    context 'create' do

      it 'should raise ArgumentError if no username or lightbox_name' do
        expect { Lightbox.create(username: 'testuser') }.to raise_error(ArgumentError)
        expect { Lightbox.create(lightbox_name: 'testlightbox') }.to raise_error(ArgumentError)
      end

      it 'should be able to create a lightbox' do
        success_resp_double = double(code: 201, to_hash: { 'lightbox_id' => '87654321' })
        req_opts = client_double.options.merge(body: { username: client_double.username, lightbox_name: 'testlb' })

        Lightbox.should_receive(:post).with("/customers/#{client_double.username}/lightboxes.json", req_opts).and_return(success_resp_double)

        lightbox = Lightbox.create(username: client_double.username, lightbox_name: 'testlb')
        lightbox.should be_an_instance_of(Lightbox)
        expect(lightbox.id).to eql 87_654_321
        expect(lightbox.name).to eql 'testlb'
      end

      it 'should raise error on creation failure' do
        resp_double = double(code: 409, body: 'Lightbox with that title already exists for user', message: 'Conflict')
        req_opts = client_double.options.merge(body: { username: client_double.username, lightbox_name: 'testlb' })

        Lightbox.should_receive(:post).with("/customers/#{client_double.username}/lightboxes.json", req_opts).and_return(resp_double)

        expect { Lightbox.create(username: client_double.username, lightbox_name: 'testlb') }.to raise_error(RuntimeError)
      end
    end

    context 'update' do
      it 'should raise ArgumentError if no username or lightbox_name' do
        expect { Lightbox.update(username: 'test') }.to raise_error(ArgumentError)
      end

      it 'should be able to update a lightbox' do
        test_id = 12_345_678
        success_resp_double = double(code: 204)
        req_opts = client_double.options.merge(body: { username: client_double.username, lightbox_name: 'updatetestlb' })

        Lightbox.should_receive(:post).with("/lightboxes/#{test_id}.json", req_opts).and_return(success_resp_double)

        expect { Lightbox.update(id: test_id, username: client_double.username, lightbox_name: 'updatetestlb') }.not_to raise_error
      end

      it 'should raise error on unsuccessful update' do
        test_id = 12_345_678
        resp_double = double(code: 400, body: 'Bad Request')
        req_opts = client_double.options.merge(body: { username: client_double.username, lightbox_name: 'updatetestlb' })

        Lightbox.should_receive(:post).with("/lightboxes/#{test_id}.json", req_opts).and_return(resp_double)
        # Lightbox.should_receive(:find).with(id: test_id).and_return(double(id: test_id, name: "mylb"))

        expect { Lightbox.update(id: test_id, username: client_double.username, lightbox_name: 'updatetestlb') }.to raise_error(RuntimeError)
      end
    end

    context 'destroy' do
      it 'should be able to destroy a lightbox' do
        test_id = 12_345_678
        success_resp_double = double(code: 204)
        req_opts = client_double.options

        Lightbox.should_receive(:delete).with("/lightboxes/#{test_id}.json", req_opts).and_return(success_resp_double)
        expect { Lightbox.destroy(id: test_id) }.not_to raise_error
      end

      it 'should raise error on unsucessful delete' do
        test_id = 12_345_678
        success_resp_double = double(code: 404, message: 'Not Found')
        req_opts = client_double.options

        Lightbox.should_receive(:delete).with("/lightboxes/#{test_id}.json", req_opts).and_return(success_resp_double)
        expect { Lightbox.destroy(id: test_id) }.to raise_error(RuntimeError)
      end
    end

    context 'add_image' do
      let(:lightbox_id) { 54_321 }
      let(:image_id) { 987_654_321 }
      context 'error' do
        it 'no lightbox_id or image_id' do
          expect { Lightbox.add_image(image_id: lightbox_id) }.to raise_error(ArgumentError)
          expect { Lightbox.add_image(lightbox_id: image_id) }.to raise_error(ArgumentError)
        end

        it 'lightbox does not exist' do
          # Lightbox.add_image()
          resp_double = double(code: 500, body: '')
          req_opts = client_double.options

          Lightbox.should_receive(:put).with("/lightboxes/#{lightbox_id}/images/#{image_id}.json?username=#{client_double.username}", req_opts).and_return(resp_double)

          expect { Lightbox.add_image(lightbox_id: lightbox_id, image_id: image_id) }.to raise_error
        end

        it 'Image does not exist' do
          resp_double = double(code: 500, body: '')
          req_opts = client_double.options

          Lightbox.should_receive(:put).with("/lightboxes/#{lightbox_id}/images/#{image_id}.json?username=#{client_double.username}", req_opts).and_return(resp_double)

          expect { Lightbox.add_image(lightbox_id: lightbox_id, image_id: image_id) }.to raise_error
        end

      end

      it 'should be able to add image' do
        success_resp_double = double(code: 200)
        req_opts = client_double.options

        Lightbox.should_receive(:put).with("/lightboxes/#{lightbox_id}/images/#{image_id}.json?username=#{client_double.username}", req_opts).and_return(success_resp_double)
        # Lightbox.should_receive(:find).with(id: lightbox_id).and_return(double(id: lightbox_id, name: "mylb"))

        expect { Lightbox.add_image(lightbox_id: lightbox_id, image_id: image_id) }.not_to raise_error
      end
    end

    context 'remove_image' do
      let(:lightbox_id) { 54_321 }
      let(:image_id) { 987_654_321 }

      context 'error' do
        it 'no lightbox_id or image_id' do
          expect { Lightbox.add_image(image_id: lightbox_id) }.to raise_error(ArgumentError)
          expect { Lightbox.add_image(lightbox_id: image_id) }.to raise_error(ArgumentError)
        end

        it 'lightbox does not exist' do
          # Lightbox.remove_image()
          resp_double = double(code: 500, body: '')
          req_opts = client_double.options

          Lightbox.should_receive(:delete).with("/lightboxes/#{lightbox_id}/images/#{image_id}.json?username=#{client_double.username}", req_opts).and_return(resp_double)

          expect { Lightbox.remove_image(lightbox_id: lightbox_id, image_id: image_id) }.to raise_error
        end
      end

      it 'should be able to remove image' do
        success_resp_double = double(code: 200)
        req_opts = client_double.options

        Lightbox.should_receive(:delete).with("/lightboxes/#{lightbox_id}/images/#{image_id}.json?username=#{client_double.username}", req_opts).and_return(success_resp_double)

        expect { Lightbox.remove_image(lightbox_id: lightbox_id, image_id: image_id) }.not_to raise_error
      end
    end

  end

end
