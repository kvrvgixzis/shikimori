describe Import::MalImage do
  let(:service) { Import::MalImage.new entry, image_url }
  let(:entry) { build :anime }
  let(:image_url) { 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/240px-PNG_transparency_demonstration_1.png' }

  before do
    allow(Import::ImagePolicy)
      .to receive(:new)
      .with(entry, image_url)
      .and_return(image_policy)
  end
  let(:image_policy) { double 'need_import?': need_import }
  subject! { service.call }

  context 'need import', :vcr do
    let(:need_import) { true }
    it { expect(entry.image).to be_present }
  end

  context 'dont need import' do
    let(:need_import) { false }
    it { expect(entry.image).to_not be_present }
  end
end
