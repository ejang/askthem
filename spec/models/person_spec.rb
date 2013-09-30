require "spec_helper"

describe Person do
  before :each do
    @metadatum = Metadatum.create(abbreviation: "vt")
    # convoluted setting of id necessary, otherwise id gets generated
    @person = Person.new(state: "vt")
    @person.id = "VTL000008"
    @person.save!
  end

  describe ".for_location" do
    it "returns matching people given a location", :vcr do
      address = "2227 Paine Turnpike South, Berlin, VT"
      expect(Person.for_location(address).first).to eq @person
    end

    context "when location is already geocoded", :vcr do
      it "returns matching people" do
        geodata = Geocoder.search("2227 Paine Turnpike South, Berlin, VT").first
        expect(Person.for_location(geodata).first).to eq @person
      end
    end
  end

  describe ".load_from_api_for_jurisdiction" do
    it "does not overwrite existing people" do
      Person.load_from_apis_for_jurisdiction("vt")
      expect(Person.connected_to("vt").count).to eq 1
    end

    # @todo fix collection clearing!!!
    it "loads people into database given a jurisdiction abbreviation", :vcr do
      # HACK, a simple destroys was not working
      Mongoid::Sessions.with_name("default").collections.each do |collection|
        collection.drop
      end
      @metadatum = Metadatum.create(abbreviation: "vt")
      # END HACK

      Person.load_from_apis_for_jurisdiction("vt")
      expect(Person.connected_to("vt").count).to eq 180
    end
  end

  describe "#votesmart_id" do
    it "returns nil when not set or set to nil" do
      expect(@person.votesmart_id).to be_nil
    end

    it "returns votesmart_id when set" do
      votesmart_id = "1234"
      @person.write_attribute :votesmart_id, votesmart_id
      expect(@person.votesmart_id).to eq votesmart_id
    end
  end

  describe "#verified?" do
    it "returns false if there is corresponding verified user identity" do
      expect(@person.verified?).to be_false
    end

    it "returns true if there is corresponding verified user identity" do
      identity = FactoryGirl.create(:identity, status: "verified")
      expect(identity.person.verified?).to be_true
    end
  end
end
