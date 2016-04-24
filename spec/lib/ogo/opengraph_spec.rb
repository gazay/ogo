require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Ogo::Opengraph do
  describe "#initialize" do
    context "with invalid src" do
      it "set title and url the same as src" do
        og = Ogo::Opengraph.new("invalid")
        og.parse
        expect(og.src).to eq "invalid"
        expect(og.title).to eq "invalid"
        expect(og.url).to eq "invalid"
      end
    end

    context "with no fallback" do
      it "should get values from opengraph metadata" do
        response = double(charset: 'UTF-8', body: File.open("#{File.dirname(__FILE__)}/../../view/opengraph.html", 'r') { |f| f.read })
        Ogo::Utils::RedirectFollower.stub(:new) { double(resolve: response) }

        og = Ogo::Opengraph.new("http://test.host", fallback: false)
        og.parse
        og.src.should == "http://test.host"
        og.title.should == "OpenGraph Title"
        og.type.should == "article"
        og.url.should == "http://test.host"
        og.description.should == "My OpenGraph sample site for Rspec"
        og.images.should == ["http://test.host/images/rock1.jpg", "http://test.host/images/rock2.jpg"]
        og.original_images.should == ["http://test.host/images/rock1.jpg", "/images/rock2.jpg"]
        og.metadata.should == {
          title: [{_value: "OpenGraph Title"}],
          type: [{_value: "article"}],
          url: [{_value: "http://test.host"}],
          description: [{_value: "My OpenGraph sample site for Rspec"}],
          image: [
            {
              _value: "http://test.host/images/rock1.jpg",
              width: [{ _value: "300" }],
              height: [{ _value: "300" }]
            },
            {
              _value: "/images/rock2.jpg",
              height: [{ _value: "1000" }]
            }
          ],
          locale: [
            {
              _value: "en_GB",
              alternate: [
                { _value: "fr_FR" },
                { _value: "es_ES" }
              ]
            }
          ]
        }
      end
    end

    context "with fallback" do
      context "when website has opengraph metadata" do
        it "should get values from opengraph metadata" do
          response = double(charset: 'UTF-8', body: File.open("#{File.dirname(__FILE__)}/../../view/opengraph.html", 'r') { |f| f.read })
          Ogo::Utils::RedirectFollower.stub(:new) { double(resolve: response) }

          og = Ogo::Opengraph.new("http://test.host")
          og.parse
          og.src.should == "http://test.host"
          og.title.should == "OpenGraph Title"
          og.type.should == "article"
          og.url.should == "http://test.host"
          og.description.should == "My OpenGraph sample site for Rspec"
          og.images.should == ["http://test.host/images/rock1.jpg", "http://test.host/images/rock2.jpg"]
        end
      end

      context "when website has no opengraph metadata" do
        it "should lookup for other data from website" do
          response = double(charset: 'UTF-8', body: File.open("#{File.dirname(__FILE__)}/../../view/opengraph_no_metadata.html", 'r') { |f| f.read })
          Ogo::Utils::RedirectFollower.stub(:new) { double(resolve: response) }

          og = Ogo::Opengraph.new("http://test.host/child_page")
          og.parse
          og.src.should == "http://test.host/child_page"
          og.title.should == "OpenGraph Title Fallback"
          og.type.should be_nil
          og.url.should == "http://test.host/child_page"
          og.description.should == "Short Description Fallback"
          og.images.should == ["http://test.host/images/wall1.jpg", "http://test.host/images/wall2.jpg"]
        end
      end
    end

    context "with body" do
      it "should parse body instead of downloading it" do
        content = File.read("#{File.dirname(__FILE__)}/../../view/opengraph.html")
        Ogo::Utils::RedirectFollower.should_not_receive(:new)

        og = Ogo::Opengraph.new(content)
        og.parse
        og.src.should == content
        og.title.should == "OpenGraph Title"
        og.type.should == "article"
        og.url.should == "http://test.host"
        og.description.should == "My OpenGraph sample site for Rspec"
        og.images.should == ["http://test.host/images/rock1.jpg", "http://test.host/images/rock2.jpg"]
      end
    end

    context "with Shift_JIS" do
      it "should get values from opengraph metadata" do
        pending 'Not working'
        response = double(charset: 'euc-jp', body: File.open("#{File.dirname(__FILE__)}/../../view/shift_jis.html", 'r') { |f| f.read })
        Ogo::Utils::RedirectFollower.stub(:new) { double(resolve: response) }

        og = Ogo::Opengraph.new("http://test.host", fallback: false)
        og.parse
        og.src.should == "http://test.host"
        og.title.should == "日本語"
      end
    end
    context "with EUC-JP" do
      it "should get values from opengraph metadata" do
        pending 'Not working'
        response = double(charset: 'euc-jp', body: File.open("#{File.dirname(__FILE__)}/../../view/euc-jp.html", 'r') { |f| f.read })
        Ogo::Utils::RedirectFollower.stub(:new) { double(resolve: response) }

        og = Ogo::Opengraph.new("http://test.host", fallback: false)
        og.parse
        og.src.should == "http://test.host"
        og.title.should == "日本語"
      end
    end
  end
end
