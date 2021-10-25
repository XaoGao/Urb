RSpec.describe Urb::Builder do
  describe '.add' do
    it 'should add one query param' do
      subject.add(q: 'cat')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should not add one query param twice' do
      subject.add(q: 'cat').add(q: 'cat')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should add some query params' do
      subject.add(q: 'cat').add(another_q: 'dog')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat', another_q: 'dog' })
    end

    it 'should not override a existed query param' do
      subject.add(q: 'cat').add(q: 'dog')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should add a query param and return the builder' do
      builder = subject.add(q: 'cat').add(q: 'dog')
      expect(builder.class).to eq(Urb::Builder)
    end
  end

  describe '.del' do
    let!(:subject) { Urb::Builder.new.add({ q: 'cat' }) }
    it 'should remove a existed query param' do
      subject.del(:q)
      expect(subject.instance_variable_get(:@queries)).to eq({})
    end

    it 'should do nothing with non existed query param' do
      subject.del(:w)
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should delete a query param and return builder' do
      builder = subject.add(w: 'dog').del(:w)
      expect(builder.class).to eq(Urb::Builder)
    end

    it 'should success add and delete a query param' do
      subject.add(w: 'dog').del(:w).add(e: 'test')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat', e: 'test' })
    end
  end

  describe '.over' do
    let(:subject) { Urb::Builder.new.add({ q: 'cat' }) }
    it 'should override a existed query param' do
      subject.over(q: 'dog')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'dog' })
    end

    it 'should do nothing with non existed query param' do
      subject.over(w: 'dog')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should override a query param and return the builder' do
      builder = subject.add(w: 'dog').over(w: 'mouse').add(e: 'test')
      expect(builder.class).to eq(Urb::Builder)
    end

    it 'should success add and override a query param' do
      subject.add(w: 'dog').over(w: 'mouse').add(e: 'test')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat', w: 'mouse', e: 'test' })
    end
  end

  describe '.append' do
    it 'should add a new segment for path' do
      subject.append(:one_segment)
      expect(subject.instance_variable_get(:@paths)).to eq(['one_segment'])
    end

    it 'should add some segments for path' do
      subject.append(:one_segment, 'two_segment')
      expect(subject.instance_variable_get(:@paths)).to eq(['one_segment', 'two_segment'])
    end

    it 'should add some segments for path and return a builder object' do
      builder = subject.append(:one_segment, 'two_segment')
      expect(builder.class).to eq(Urb::Builder)
    end
  end

  describe '.cut' do
    it 'should delete a segment for path' do
      subject.append(:first, :second).cut(:first)
      expect(subject.instance_variable_get(:@paths)).to eq(['second'])
    end

    it 'should do nothing when segments is not exist' do
      subject.append(:first, :second).cut(:cat)
      expect(subject.instance_variable_get(:@paths)).to eq(['first', 'second'])
    end

    it 'should delete segments for path and return a builder object' do
      builder = subject.append(:first, 'second').cut(:first)
      expect(builder.class).to eq(Urb::Builder)
    end
  end

  describe '.scheme' do
    it "should set a new scheme 'http'" do
      subject.scheme 'http'
      expect(subject.instance_variable_get(:@scheme)).to eq('http')
    end

    it "should set a new scheme 'https'" do
      subject.scheme 'https'
      expect(subject.instance_variable_get(:@scheme)).to eq('https')
    end

    it 'should set a new scheme and return the builder' do
      builder = subject.scheme 'https'
      expect(builder.class).to eq(Urb::Builder)
    end

    it 'raises when set a invalid scheme' do
      expect { subject.scheme 'wrong protocol' }.to raise_error(Urb::InvalidUrl)
    end
  end

  describe '.host' do
    describe '.host_valid?' do
      it 'should return truthy result' do
        expect(subject.send(:host_valid?, 'example.com')).to be_truthy
      end

      context 'should return falsthy result' do
        it 'have not dot' do
          expect(subject.send(:host_valid?, 'example')).to be_falsey
        end

        it 'empty host' do
          expect(subject.send(:host_valid?, '')).to be_falsey
        end

        it 'send invalid object' do
          expect(subject.send(:host_valid?, 1)).to be_falsey
        end
      end
    end

    it 'should set a new host' do
      subject.host 'examplehost.com'
      expect(subject.instance_variable_get(:@host)).to eq('examplehost.com')
    end

    it 'should set a new host and return the builder' do
      builder = subject.host 'examplehost.com'
      expect(builder.class).to eq(Urb::Builder)
    end
  end

  describe '.port' do
    describe '.port_valid?' do
      it 'should return truthy result' do
        expect(subject.send(:port_valid?, 1234)).to be_truthy
      end

      context 'should return falsthy result' do
        it 'is not number' do
          expect(subject.send(:port_valid?, 'example')).to be_falsey
        end

        it 'empty port' do
          expect(subject.send(:port_valid?, '')).to be_falsey
        end

        it 'size is not 4' do
          expect(subject.send(:port_valid?, 1)).to be_falsey
        end
      end
    end

    it 'should set a new port' do
      subject.port 3000
      expect(subject.instance_variable_get(:@port)).to eq(3000)
    end

    it 'should set a new port and return the builder' do
      builder = subject.port 3000
      expect(builder.class).to eq(Urb::Builder)
    end
  end

  describe '.parse!' do
    let(:empty_subject) { Urb::Builder.new }
    let(:subject_with_valid_url) { Urb::Builder.new('http://google.com:4432/fisrt-segnemt/last-segment?q=some_data&w=second_data') }
    let(:subject_with_simple_url) { Urb::Builder.new('https://www.google.com') }

    it 'split empty url to default fields' do
      expect(empty_subject.instance_variable_get(:@scheme)).to eq('')
      expect(empty_subject.instance_variable_get(:@host)).to eq('')
      expect(empty_subject.instance_variable_get(:@port)).to eq('')
      expect(empty_subject.instance_variable_get(:@paths)).to eq([])
      expect(empty_subject.instance_variable_get(:@queries)).to eq({})
    end

    it 'split valid url to fields' do
      expect(subject_with_valid_url.instance_variable_get(:@scheme)).to eq('http')
      expect(subject_with_valid_url.instance_variable_get(:@host)).to eq('google.com')
      expect(subject_with_valid_url.instance_variable_get(:@port)).to eq('4432')
      expect(subject_with_valid_url.instance_variable_get(:@paths)).to eq(%w[fisrt-segnemt last-segment])
      expect(subject_with_valid_url.instance_variable_get(:@queries)).to eq({ q: 'some_data', w: 'second_data' })
    end

    it 'split simple url to fields' do
      expect(subject_with_simple_url.instance_variable_get(:@scheme)).to eq('https')
      expect(subject_with_simple_url.instance_variable_get(:@host)).to eq('www.google.com')
      expect(subject_with_simple_url.instance_variable_get(:@port)).to eq('')
      expect(subject_with_simple_url.instance_variable_get(:@paths)).to eq([])
      expect(subject_with_simple_url.instance_variable_get(:@queries)).to eq({})
    end
  end

  describe 'build url' do
    context '.build_as_string' do
      it 'should create a url string' do
        subject.instance_variable_set(:@scheme, 'https')
        subject.instance_variable_set(:@host, 'google.com')
        subject.instance_variable_set(:@port, '3000')
        subject.instance_variable_set(:@paths, ['first', 'last'])
        subject.instance_variable_set(:@queries, { q: 'one', w: 'two'} )
        expect(subject.build_as_string).to eq('https://google.com:3000/first/last?q=one&w=two')
      end
    end

    context 'build_as_url' do
      it 'should create a url string' do
        subject.instance_variable_set(:@scheme, 'https')
        subject.instance_variable_set(:@host, 'google.com')
        subject.instance_variable_set(:@port, '3000')
        subject.instance_variable_set(:@paths, ['first', 'last'])
        subject.instance_variable_set(:@queries, { q: 'one', w: 'two'} )
        expect(subject.build_as_url).to eq(URI('https://google.com:3000/first/last?q=one&w=two'))
      end
    end
  end
end
