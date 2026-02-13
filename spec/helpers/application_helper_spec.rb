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

  describe "#bootstrap_toast_class_for" do
    context "standard flash types" do
      {
        success: "text-bg-success",
        error:   "text-bg-danger",
        alert:   "text-bg-warning",
        notice:  "text-bg-info"
      }.each do |flash_type, expected_class|
        it "transforms #{flash_type.inspect} to #{expected_class}" do
          expect(helper.bootstrap_toast_class_for(flash_type)).to eq(expected_class)
        end

        it "handles string input for #{flash_type.inspect}" do
          expect(helper.bootstrap_toast_class_for(flash_type.to_s)).to eq(expected_class)
        end
      end
    end

    context "unknown flash types" do
      it "returns the flash type as text-bg- prefix when it doesn't contain 'alert-'" do
        # When bootstrap_class_for returns just the string (e.g., "foo"),
        # the sub won't find 'alert-' so it returns the original string
        expect(helper.bootstrap_toast_class_for(:custom)).to eq("custom")
        expect(helper.bootstrap_toast_class_for("info-message")).to eq("info-message")
      end
    end

    context "transformation behavior" do
      it "correctly substitutes 'alert-' with 'text-bg-'" do
        # Verify the transformation is working correctly
        result = helper.bootstrap_toast_class_for(:success)
        expect(result).to start_with("text-bg-")
        expect(result).not_to include("alert-")
      end

      it "delegates to bootstrap_class_for first" do
        # Verify it's using bootstrap_class_for under the hood
        allow(helper).to receive(:bootstrap_class_for).with(:success).and_return("alert-success")
        expect(helper.bootstrap_toast_class_for(:success)).to eq("text-bg-success")
        expect(helper).to have_received(:bootstrap_class_for).with(:success)
      end
    end

    context "edge cases" do
      it "raises NoMethodError for nil input (inherited from bootstrap_class_for)" do
        expect { helper.bootstrap_toast_class_for(nil) }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#article_preview" do
    describe "length conditional branches" do
      context "when text is shorter than specified length" do
        it "returns the full text without truncation" do
          content = "This is a short article."
          result = helper.article_preview(content, length: 200)

          expect(result).to eq("This is a short article.")
          expect(result).not_to include("...")
        end

        it "returns the full text when exactly at the length limit" do
          content = "a" * 200
          result = helper.article_preview(content, length: 200)

          expect(result.length).to eq(200)
          expect(result).not_to include("...")
        end
      end

      context "when text is longer than specified length" do
        it "truncates the text and adds ellipsis" do
          content = "This is a very long article that should be truncated. " * 10
          result = helper.article_preview(content, length: 100)

          expect(result.length).to be <= 100
          expect(result).to end_with("...")
        end

        it "truncates at word boundaries using separator" do
          content = "The quick brown fox jumps over the lazy dog and continues running through the forest"
          result = helper.article_preview(content, length: 50)

          expect(result).to end_with("...")
          expect(result.length).to be <= 50
          # Verify it ends with complete words, not partial words
          # The result should be "The quick brown fox jumps over the lazy dog and..."
          expect(result).to eq("The quick brown fox jumps over the lazy dog and...")
          # Verify that if we removed the ellipsis, we'd have complete words
          words_part = result.gsub(/\.\.\./, '').strip
          expect(words_part.split.last).to eq("and") # Complete word, not "a" or "an"
        end

        it "respects custom length parameter" do
          content = "a" * 500
          result = helper.article_preview(content, length: 150)

          expect(result.length).to be <= 150
          expect(result).to end_with("...")
        end
      end
    end

    describe "edge cases" do
      it "returns empty string for nil content" do
        expect(helper.article_preview(nil)).to eq("")
      end

      it "returns empty string for blank content" do
        expect(helper.article_preview("")).to eq("")
        expect(helper.article_preview("   ")).to eq("")
      end

      it "uses default length of 200 when not specified" do
        content = "a" * 250
        result = helper.article_preview(content)

        expect(result.length).to be <= 200
      end
    end

    describe "markdown removal" do
      it "removes fenced code blocks" do
        content = "Some text ```ruby\ncode here\n``` more text"
        result = helper.article_preview(content, length: 200)

        expect(result).not_to include("```")
        expect(result).not_to include("code here")
        expect(result).to include("Some text")
        expect(result).to include("more text")
      end

      it "removes inline code" do
        content = "Use `console.log()` for debugging"
        result = helper.article_preview(content, length: 200)

        expect(result).not_to include("`")
        expect(result).to include("Use")
        expect(result).to include("for debugging")
      end

      it "removes markdown headers" do
        content = "# Main Title\n## Subtitle\nSome content"
        result = helper.article_preview(content, length: 200)

        expect(result).not_to include("#")
        expect(result).to include("Main Title")
        expect(result).to include("Subtitle")
      end

      it "removes markdown links and keeps link text" do
        content = "Check out [this article](https://example.com) for more info"
        result = helper.article_preview(content, length: 200)

        expect(result).to include("this article")
        expect(result).not_to include("[")
        expect(result).not_to include("](")
        expect(result).not_to include("https://example.com")
      end

      it "removes bold and italic formatting" do
        content = "This is **bold** and *italic* text"
        result = helper.article_preview(content, length: 200)

        expect(result).to include("bold")
        expect(result).to include("italic")
        expect(result).not_to include("**")
        expect(result).not_to include("*")
      end

      it "cleans up extra whitespace and newlines" do
        content = "Line 1\n\n\nLine 2\n\n\n\nLine 3"
        result = helper.article_preview(content, length: 200)

        expect(result).to eq("Line 1 Line 2 Line 3")
      end
    end

    describe "combined scenarios" do
      it "removes markdown and truncates when content is long" do
        content = "# Article Title\n\nThis is a **very long** article with `code` and [links](http://example.com). " * 5
        result = helper.article_preview(content, length: 100)

        expect(result.length).to be <= 100
        expect(result).to end_with("...")
        expect(result).not_to include("#")
        expect(result).not_to include("**")
        expect(result).not_to include("`")
        expect(result).not_to include("[")
      end

      it "handles complex markdown with code blocks and returns short text" do
        content = <<~MARKDOWN
          # Introduction

          Here's some code:

          ```ruby
          def hello
            puts "world"
          end
          ```

          And some more text.
        MARKDOWN

        result = helper.article_preview(content, length: 200)

        expect(result).to include("Introduction")
        expect(result).to include("some more text")
        expect(result).not_to include("```")
        expect(result).not_to include("def hello")
      end
    end
  end
end
