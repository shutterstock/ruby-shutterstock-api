require 'spec_helper'

describe Driver do
  describe "#json_true?" do
    it "returns true for any truthy json value" do
      Driver::TRUTHY_JSON_VALUES.each do |value|
        subject.json_true?(value).should be_true
      end
    end

    it "returns false for null" do
      subject.json_true?(nil).should be_false
    end

    it "return false for non-truthy values" do
      subject.json_true?("FALSE").should be_false
    end
  end

end
