require "spec_helper"

module Spree
  module Hub
    describe ResponderSerializer do
      let(:responder) {Responder.new("12355","Order abc124 was added")}
      it "correctly serializes a Hub::Responder" do
        json_response = "{\"request_id\":\"12355\",\"summary\":\"Order abc124 was added\"}"
        expect(ResponderSerializer.new(responder, root: false).to_json).to eql json_response
      end
    end
  end
end
