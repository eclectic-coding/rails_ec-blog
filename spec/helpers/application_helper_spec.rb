require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#app_title" do
    context "when the application module name is CamelCase" do
      before do
        allow(Rails.application.class).to receive(:module_parent_name).and_return("EclecticCoding")
      end

      it "inserts spaces and titleizes the name" do
        expect(helper.app_title).to eq("Eclectic Coding")
      end
    end

    context "when the application module name contains underscores" do
      before do
        allow(Rails.application.class).to receive(:module_parent_name).and_return("my_app")
      end

      it "humanizes and titleizes the name" do
        expect(helper.app_title).to eq("My App")
      end
    end

    context "when the application module name is blank or nil" do
      it "falls back to 'Application' for blank string" do
        allow(Rails.application.class).to receive(:module_parent_name).and_return("")
        expect(helper.app_title).to eq("Application")
      end

      it "falls back to 'Application' for nil" do
        allow(Rails.application.class).to receive(:module_parent_name).and_return(nil)
        expect(helper.app_title).to eq("Application")
      end
    end
  end

  describe "#bootstrap_class_for" do
    {
      success: "alert-success",
      error:   "alert-danger",
      alert:   "alert-warning",
      notice:  "alert-info"
    }.each do |key, expected|
      it "maps #{key.inspect} to #{expected} (and handles string input)" do
        expect(helper.bootstrap_class_for(key)).to eq(expected)
        expect(helper.bootstrap_class_for(key.to_s)).to eq(expected)
      end
    end

    it "returns the string form for unknown flash types" do
      expect(helper.bootstrap_class_for(:foo)).to eq("foo")
      expect(helper.bootstrap_class_for('bar')).to eq("bar")
    end

    it "raises NoMethodError for nil input (matching current helper implementation)" do
      expect { helper.bootstrap_class_for(nil) }.to raise_error(NoMethodError)
    end
  end
end
