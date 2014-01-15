require 'spec_helper'

module NetsuiteIntegration
  describe Services::InventoryItem do
    include_examples "config hash"

    subject { described_class.new config }

    let(:items) do
      VCR.use_cassette("inventory_item/search") do
        subject.latest
      end
    end

    it "ensures items are ordered by last_modified_date" do
      expect(items.count).to be > 1

      (1..(items.count - 1)).each do |time|
        expect(items[time].last_modified_date).to be >= items[time-1].last_modified_date
      end
    end

    describe "#find_by_name" do
      context "item exists" do
        it "returns the item" do
          VCR.use_cassette("inventory_item/find_by_name") do
            expect(subject.find_by_name('Spree Taxes').internal_id).to eq("1124")
          end
        end
      end

      context "item not found" do
        it "returns empty array" do
          VCR.use_cassette("inventory_item/find_by_name_not_found") do
            expect(subject.find_by_name('Cucamonga Oh Yeah!')).to be_false
          end
        end
      end
    end

    it "finds inventory item given item id" do
      VCR.use_cassette("inventory_item/find_by_item_id") do
        item = subject.find_by_item_id 'Test-Sameer5'
        expect(item.item_id).to eq 'Test-Sameer5' 
      end
    end
  end
end
