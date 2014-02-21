require 'spec_helper'

describe Image do
  before do
    client
  end

  let(:id) { 118_139_110 }
  subject(:image) { Image.find(id: id)  }

  it 'Should return an Image object' do
    expect(Image).to respond_to(:find)
    expect(image).to_not be_nil

    expect(image.id).to eql id
    expect(image.sizes).to_not be_empty
  end

  it 'should return similar images' do
    result = Image.find_similar(id)
    expect(result).to_not be_nil
    expect(result).to be_kind_of Array
    expect(result).to be_kind_of Images
    expect(result[0]).to be_kind_of Image
    expect(result.raw_data).to be_kind_of Hash
    expect(result.page).to be 0
    expect(result.total_count).to be > 200
    expect(result.search_src_id).to_not be_nil

    # ["count", "page", "sort_method", "searchSrcID", "results"]
  end

  it 'should find similar images, given an image' do
    expect(image.find_similar).to be_kind_of Images
  end

  it 'should be able to search for images based on searchterm' do
    results = Image.search('purple cat')
    expect(results).to be_kind_of Images
    expect(results.size).to be > 100
    # TODO: test all of these search options
    # searchterm, category_id, photographer_name, submmiter_id,
    # color
  end
end
