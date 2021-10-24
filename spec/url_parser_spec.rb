RSpec.describe Urb::UrlParser do
  describe 'a valid url' do
    let(:subject) { Urb::UrlParser.new('https://google.com:4432/first-segment/last-segment?q=first&w=second') }
    context '.parse_scheme' do
      it "should return a 'https' scheme" do
        expect(subject.send(:parse_scheme, StringScanner.new('https://google.com:4432/first-segment/last-segment?q=first&w=second'))).to eq('https')
      end
    end

    context '.parse_host' do
      it "should return a 'google.com' host" do
        expect(subject.send(:parse_host, StringScanner.new('google.com:4432/first-segment/last-segment?q=first&w=second'))).to eq('google.com')
      end
    end

    context '.parse_host' do
      it "should return a '4432' port" do
        expect(subject.send(:parse_port, StringScanner.new(':4432/first-segment/last-segment?q=first&w=second'))).to eq('4432')
      end
    end

    context '.parse_paths' do
      it 'should return a array parths' do
        expect(subject.send(:parse_paths, StringScanner.new('/first-segment/last-segment?q=first&w=second'))).to eq(['first-segment', 'last-segment'])
      end
    end

    context '.parse_queries' do
      it 'should return a hash queries' do
        expect(subject.send(:parse_queries, StringScanner.new('?q=first&w=second'))).to eq({ q: 'first', w: 'second' })
      end
    end

    context '.parse' do
      it 'should set all fields' do
        subject.parse
        expect(subject.scheme).to eq('https')
        expect(subject.host).to eq('google.com')
        expect(subject.port).to eq('4432')
        expect(subject.paths).to eq(['first-segment', 'last-segment'])
        expect(subject.queries).to eq({ q: 'first', w: 'second' })
      end
    end
  end
end
