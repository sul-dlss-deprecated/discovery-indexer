require 'spec_helper'

describe DiscoveryIndexer::Collection do
  let(:druid) { 'abc123' }
  let(:subject) { described_class.new(druid) }
  let(:purl_model) { double('purl-model', label: 'Title', catkey: nil) }
  let(:purl_model_ckey) { double('purl-model', label: 'Title', catkey: '12345') }

  describe '.searchworks_id' do
    it 'should return druid if no catkey' do
      allow(subject).to receive_messages(purl_model: purl_model)
      expect(subject.searchworks_id).to eq('abc123')
    end
    it 'should return catkey if catkey exists' do
      allow(subject).to receive_messages(purl_model: purl_model_ckey)
      expect(subject.searchworks_id).to eq('12345')
    end
  end
  describe '.title' do
    it 'should return title' do
      allow(subject).to receive_messages(purl_model: purl_model_ckey)
      expect(subject.title).to eq('Title')
    end
  end
end
