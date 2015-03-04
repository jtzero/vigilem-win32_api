shared_examples 'attributes_and_size_test' do
    
  it 'will have methods as attrs' do
    expect(described_class.new).to respond_to(*ary)
  end
  
  it %q(will have an size eql to it's layout types sizes) do
    expect(described_class.new.to_ptr.type_size).to eql(sze)
  end
end