require 'spec_helper'

describe DiscoveryIndexer::Collection do
  let(:druid) { 'abc123' }
  let(:subject) { described_class.new(druid) }
  let(:purl_model_no_ckey) { double('purl-model', label: 'Title_no_ckey', catkey: nil) }
  let(:purl_model_w_ckey) { double('purl-model', label: 'Title_ckey', catkey: '12345') }

  describe '#searchworks_id' do
    it 'druid if no catkey' do
      allow(subject).to receive_messages(purl_model: purl_model_no_ckey)
      expect(subject.searchworks_id).to eq('abc123')
    end
    it 'catkey if catkey exists' do
      allow(subject).to receive_messages(purl_model: purl_model_w_ckey)
      expect(subject.searchworks_id).to eq('12345')
    end
  end

  describe '#title' do
    it 'purl_model.label' do
      allow(subject).to receive_messages(purl_model: purl_model_w_ckey)
      expect(subject.title).to eq('Title_ckey')
      allow(subject).to receive_messages(purl_model: purl_model_no_ckey)
      expect(subject.title).to eq('Title_no_ckey')
    end
  end

  context '#collection_info' do
    it '{title: nil, ckey: nnn} if no purl_model.label' do
      allow(subject).to receive(:purl_model).and_return(double('purl-model', label: nil, catkey: '666'))
      expect(subject.send(:collection_info)).to eq(title: nil, ckey: '666')
    end
    it '{title: ttt, catkey: nnn} if public_xml has ckey' do
      allow(subject).to receive(:purl_model).and_return(purl_model_w_ckey)
      expect(subject.send(:collection_info)).to eq(title: 'Title_ckey', ckey: '12345')
    end
    it '{title: ttt} if public_xml has no ckey' do
      expect(subject).to receive_messages(purl_model: purl_model_no_ckey)
      expect(subject.send(:collection_info)).to eq(title: 'Title_no_ckey', ckey: nil)
    end
  end
end
