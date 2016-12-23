require 'spec_helper'

describe Filter do
  before {
    @filter = {name: 'MyFilter', filter: '{"married"=>{"29609"=>{"v"=>"_discard"}, "38658"=>{"v"=>"true"}, "38676"=>{"v"=>"false"}}}', class_name: 'user'}
  }


  it 'is no valid without anything' do
    filter = Filter.create
    expect(filter).not_to be_valid
  end

  it 'is valid with all the attributes' do
    filter = Filter.new(
        name:'MyFilter',
        filter: '{"married"=>{"29609"=>{"v"=>"_discard"}}}',
        class_name: 'book')
    expect(filter).to be_valid
  end

  it 'is invalid without a name' do
    @filter.delete(:name)
    filter = Filter.new @filter
    expect(filter).not_to be_valid
  end

  it 'is invalid without a filter' do
    @filter.delete(:filter)
    filter = Filter.new @filter
    expect(filter).not_to be_valid
  end

  it 'is invalid without a class_name' do
    @filter.delete(:class_name)
    filter = Filter.new @filter
    expect(filter).not_to be_valid
  end

  it 'is invalid with a duplicate name' do
    Filter.create @filter
    filter = Filter.new(
        name:'MyFilter',
        filter: '{"married"=>{"29609"=>{"v"=>"_discard"}}}',
        class_name: 'book')
    expect(filter).not_to be_valid
  end

  it 'is invalid with a duplicate filter' do
    Filter.create @filter
    filter = Filter.new(
        name:'MyFilter1',
        filter: '{"married"=>{"29609"=>{"v"=>"_discard"}, "38658"=>{"v"=>"true"}, "38676"=>{"v"=>"false"}}}',
        class_name: 'book')
    expect(filter).not_to be_valid
  end

  it 'is invalid with a duplicate name and filter' do
    Filter.create @filter
    filter = Filter.new(
        name:'MyFilter',
        filter: '{"married"=>{"29609"=>{"v"=>"_discard"}, "38658"=>{"v"=>"true"}, "38676"=>{"v"=>"false"}}}',
        class_name: 'book')
    expect(filter).not_to be_valid
  end

=begin
  it 'is valid ...' do
    count = Filter.count
    puts count
    Filter.create(
        name:'MyFilter1',
        filter: '{"married"=>{"29609"=>{"v"=>"_discard"}}}',
        class_name: 'book')
    puts Filter.count + 1
    count2 = Filter.count + 1
    expect(count2) == count
  end
=end


end