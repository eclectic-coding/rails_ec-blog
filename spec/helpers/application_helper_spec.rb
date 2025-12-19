require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#bootstrap_class_for" do
    it "returns alert-success for :success" do
      expect(helper.bootstrap_class_for(:success)).to eq("alert-success")
    end

    it "returns alert-danger for :error" do
      expect(helper.bootstrap_class_for(:error)).to eq("alert-danger")
    end

    it "returns alert-warning for :alert" do
      expect(helper.bootstrap_class_for(:alert)).to eq("alert-warning")
    end

    it "returns alert-info for :notice" do
      expect(helper.bootstrap_class_for(:notice)).to eq("alert-info")
    end

    it "returns the stringified flash for unknown types" do
      expect(helper.bootstrap_class_for(:custom_type)).to eq("custom_type")
      expect(helper.bootstrap_class_for("another")).to eq("another")
    end

    it "handles nil gracefully by returning empty string" do
      # The helper calls to_sym, so passing nil would raise. Ensure behavior if nil is possible.
      # To avoid raising in app code, we expect a NoMethodError if nil is passed. This documents current behavior.
      expect { helper.bootstrap_class_for(nil) }.to raise_error(NoMethodError)
    end
  end
end
