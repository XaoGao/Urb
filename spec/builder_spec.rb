RSpec.describe Urb::Builder do
  describe '.add' do
    it 'should add one query param' do
      subject.add(q: 'cat')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should not add one query param twice' do
      subject
        .add(q: 'cat')
        .add(q: 'cat')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should add some query params' do
      subject
        .add(q: 'cat')
        .add(another_q: 'dog')
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
    it 'should over a existed query param' do
      subject.over(q: 'dog')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'dog' })
    end

    it 'should do nothing with non existed query param' do
      subject.over(w: 'dog')
      expect(subject.instance_variable_get(:@queries)).to eq({ q: 'cat' })
    end

    it 'should over a query param and return the builder' do
      builder = subject.add(w: 'dog').over(w: 'mouse').add(e: 'test')
      expect(builder.class).to eq(Urb::Builder)
    end

    it 'should success add and over a query param' do
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

  describe '.scheme' do
    it "set a new scheme 'http'" do
      subject.scheme 'http'
      expect(subject.instance_variable_get(:@scheme)).to eq('http')
    end

    it "set a new scheme 'https'" do
      subject.scheme 'https'
      expect(subject.instance_variable_get(:@scheme)).to eq('https')
    end

    it 'set a new scheme and return builder' do
      builder = subject.scheme 'https'
      expect(builder.class).to eq(Urb::Builder)
    end

    it 'raises when set a invalid scheme' do
      expect { subject.scheme 'wrong protocol' }.to raise_error(Urb::InvalidUrl)
    end
  end
end
