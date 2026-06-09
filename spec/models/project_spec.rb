require "rails_helper"

RSpec.describe Project, type: :model do
  describe "validations" do
    it "is valid with required attributes" do
      expect(build(:project)).to be_valid
    end

    it "requires name" do
      expect(build(:project, name: nil)).not_to be_valid
    end

    it "requires url" do
      expect(build(:project, url: nil)).not_to be_valid
    end

    it "requires project_type to be in the allowlist" do
      expect(build(:project, project_type: "invalid")).not_to be_valid
    end

    it "accepts all valid project types" do
      Project::TYPES.each do |type|
        expect(build(:project, project_type: type)).to be_valid
      end
    end

    it "allows rubygem_name to be nil" do
      expect(build(:project, rubygem_name: nil)).to be_valid
    end

    it "enforces uniqueness of rubygem_name when present" do
      create(:project, :rubygem, rubygem_name: "my-gem")
      expect(build(:project, :rubygem, rubygem_name: "my-gem")).not_to be_valid
    end
  end

  describe "defaults" do
    it "defaults is_featured to false" do
      project = create(:project)
      expect(project.is_featured).to be false
    end
  end

  describe "scopes" do
    let!(:unfeatured) { create(:project) }
    let!(:featured)   { create(:project, :featured) }

    describe ".featured" do
      it "returns only featured projects" do
        expect(Project.featured).to contain_exactly(featured)
      end
    end

    describe ".featured_first" do
      it "returns featured projects before unfeatured" do
        results = Project.featured_first
        expect(results.first).to eq(featured)
      end
    end

    describe ".by_position" do
      it "orders projects with nulls last" do
        p1 = create(:project, position: 2)
        p2 = create(:project, position: 1)
        p3 = create(:project, position: nil)

        results = Project.where(id: [p1.id, p2.id, p3.id]).by_position
        expect(results.map(&:id)).to eq([p2.id, p1.id, p3.id])
      end
    end
  end

  describe "#rubygem?" do
    it "returns true for rubygem type" do
      expect(build(:project, :rubygem).rubygem?).to be true
    end

    it "returns false for other types" do
      expect(build(:project, project_type: "github").rubygem?).to be false
    end
  end
end
