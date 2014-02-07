require 'spec_helper'

describe WrapIt::HTMLClass do
  describe 'self.sanitize' do
    it { expect(described_class.sanitize).to match_array [] }

    it { expect(described_class.sanitize('test')).to match_array %w(test) }

    it 'removes all except strings and symbols' do
      expect(described_class.sanitize(0, :some, true, nil, Object, 'test'))
        .to match_array %w(some test)
    end

    it 'removes repeated classes' do
      expect(described_class.sanitize('a', :a, 'b')).to match_array %w(a b)
    end

    it 'flats recursive arrays' do
      expect(described_class.sanitize(:a, [:b, [:c, :d, :a]]))
        .to match_array %w(a b c d)
    end

    it 'removes repeated and trailing spaces' do
      expect(described_class.sanitize("  some \n\ttest", 'class array  '))
        .to match_array %w(some test class array)
    end
  end

  it 'overrides #&' do
    subject << 'a b c'
    expect(subject & %w(b d c)).to match_array %w(b c)
    expect(subject & 'b').to match_array %w(b)
    expect(subject & %w(b)).to be_kind_of described_class
  end

  it 'overrides #<<' do
    expect(subject << 'a').to equal subject
    expect(subject << [0, 1, :b]).to match_array %w(a b)
    expect(subject << 'c').to match_array %w(a b c)
  end

  it 'overrides #+' do
    subject << 'a b c'
    expect(subject + %w(b d c)).to match_array %w(a b c d)
    expect(subject + 'b').to match_array %w(a b c)
    expect(subject + %w(b)).to be_kind_of described_class
  end

  it 'overrides #-' do
    subject << 'a b c d'
    expect(subject - %w(b c j)).to match_array %w(a d)
    expect(subject - 'd').to match_array %w(a b c)
    expect(subject - %w(b)).to be_kind_of described_class
  end

  it 'overrides #[] and #slice' do
    subject << 'a b c'
    %i([] slice).each do |m|
      expect(subject.send(m, 1)).to eq 'b'
      expect(subject.send(m, 0, 2)).to match_array %w(a b)
      expect(subject.send(m, 0, 2)).to be_kind_of described_class
      expect(subject.send(m, 1..-1)).to match_array %w(b c)
      expect(subject.send(m, 1..-1)).to be_kind_of described_class
    end
  end

  it 'overrides #slice!' do
    subject = WrapIt::HTMLClass.new('a b c')
    expect(subject.slice!(1)).to eq 'b'
    expect(subject).to match_array %w(a c)
    subject = WrapIt::HTMLClass.new('a b c')
    expect(subject.slice!(0, 2)).to match_array %w(a b)
    expect(subject).to match_array %w(c)
    subject = WrapIt::HTMLClass.new('a b c')
    expect(subject.slice!(0, 2)).to be_kind_of described_class
    subject = WrapIt::HTMLClass.new('a b c')
    expect(subject.slice!(1..-1)).to match_array %w(b c)
    expect(subject).to match_array %w(a)
    subject = WrapIt::HTMLClass.new('a b c')
    expect(subject.slice!(1..-1)).to be_kind_of described_class
  end

  it 'overrides #clear' do
    subject << 'a b c'
    expect(subject.clear).to equal subject
    expect(subject).to be_empty
  end

  it 'overrides #collect' do
    subject << 'a b c'
    expect(subject.collect { |x| x + '1' }).to match_array %w(a1 b1 c1)
    expect(subject.collect { }).to be_kind_of described_class
    expect(subject.collect).to be_kind_of Enumerator
  end

  it 'overrides #collect!' do
    subject << 'a b c'
    expect(subject.collect! { |x| [x, 'n'] }).to match_array %w(a b c n)
    expect(subject.collect! { }).to equal subject
    expect(subject.collect!).to be_kind_of Enumerator
  end

  it 'overrides #concat' do
    subject << 'a b c'
    expect(subject.concat(%w(b d c))).to match_array %w(a b c d)
    expect(subject.concat('e')).to match_array %w(a b c d e)
    expect(subject.concat(%w(b))).to equal subject
  end

  it 'overrides #delete' do
    subject << 'a b2 c'
    expect(subject.delete(:a)).to match_array %w(b2 c)
    expect(subject.delete('d')).to match_array %w(b2 c)
    expect(subject.delete('d')).to equal subject
    expect(subject.delete('d', :b2)).to match_array %w(c)
    subject << 'a b2'
    expect(subject.delete(/.\d/, 'c')).to match_array %w(a)
    expect(subject.delete { |x| x == 'a' }).to be_empty
  end

  %i(index rindex).each do |m|
    it "overrides ##{m}" do
      subject << 'a b2 c'
      expect(subject.index(:a)).to eq 0
      expect(subject.index('d')).to be_nil
      expect(subject.index(['d', :b2])).to eq 1
      expect(subject.index(/.\d/)).to eq 1
      expect(subject.index { |x| x == 'c' }).to eq 2
      expect(subject.index).to be_kind_of Enumerator
    end
  end

  it 'overrides #drop' do
    subject << 'a b c'
    expect(subject.drop(1)).to match_array %w(b c)
    expect(subject.drop(1)).to be_kind_of described_class
    expect(subject).to match_array %w(a b c)
  end

  {drop_while: %w(c d), reject: %w(c), select: %w(a b d)}.each do |m, v|
    it "overrides ##{m}" do
      subject << 'a b c d'
      expect(subject.send(m) { |x| x != 'c' }).to match_array v
      expect(subject.send(m) { |x| x != 'c' }).to be_kind_of described_class
      expect(subject.send(m)).to be_kind_of Enumerator
    end
  end

  {map: %w(ac bc cc dc)}.each do |m, v|
    it "overrides ##{m}" do
      subject << 'a b c d'
      expect(subject.send(m) { |x| x = x + 'c' }).to match_array v
      expect(subject.send(m) { |x| x = x + 'c' }).to be_kind_of described_class
      expect(subject.send(m)).to be_kind_of Enumerator
    end
  end

  it "overrides #map!" do
    subject << 'a b c d'
    expect(subject.map! { |x| x = x + 'c' }).to equal subject
    expect(subject).to match_array %w(ac bc cc dc)
    expect(subject.map!).to be_kind_of Enumerator
  end

  it "overrides #reject!" do
    subject << 'a b1 c1 d'
    expect(subject.reject! { |x| /\d/ =~ x }).to equal subject
    expect(subject).to match_array %w(a d)
    expect(subject.reject!).to be_kind_of Enumerator
  end

  %i(each each_index).each do |m|
    it "overrides ##{m}" do
      subject << 'a b c'
      i = 0
      expect(subject.send(m) { |x| i += 1 }).to equal subject
      expect(i).to eq 3
      expect(subject.send(m)).to be_kind_of Enumerator
    end
  end

  {first: %w(a b), last: %w(c b)}.each do |m, v|
    it "overrides ##{m}" do
      expect(subject.send(m)).to be_nil
      subject << 'a b c'
      expect(subject.send(m)).to eq v[0]
      expect(subject.send(m, 2)).to match_array v
      expect(subject.send(m, 2)).to be_kind_of described_class
    end
  end

  it "overrides #pop" do
    expect(subject.pop).to be_nil
    subject << 'a b c'
    expect(subject.pop).to eq 'c'
    expect(subject).to match_array %w(a b)
    subject << 'c'
    expect(subject.pop(2)).to match_array %w(b c)
    expect(subject).to match_array %w(a)
    subject << 'b c'
    expect(subject.pop(2)).to be_kind_of described_class
  end

  it "overrides #shift" do
    expect(subject.shift).to be_nil
    subject << 'a b c'
    expect(subject.shift).to eq 'a'
    expect(subject).to match_array %w(b c)
    subject << 'a'
    expect(subject.shift(2)).to match_array %w(b c)
    expect(subject).to match_array %w(a)
    subject << 'b c'
    expect(subject.shift(2)).to be_kind_of described_class
  end

  it 'overrides #include?' do
    subject << 'a b2 c'
    expect(subject.include?(:a)).to be_true
    expect(subject.include?('d')).to be_false
    expect(subject.include?('d', :b2)).to be_false
    expect(subject.include?('a', :b2)).to be_true
    expect(subject.include?(/.\d/)).to be_true
    expect(subject.include?(proc { |x| x == 'c' })).to be_true
  end

  it 'overrides #replace' do
    subject << 'a b c'
    expect(subject.replace('d e f')).to match_array %w(d e f)
    expect(subject.replace('a b')).to equal subject
  end

  it 'overrides #keep_if' do
    subject << 'a b c'
    expect(subject.keep_if { |x| x != 'c' }).to match_array %w(a b)
    expect(subject.keep_if { |x| x != 'c' }).to equal subject
    expect(subject.keep_if).to be_kind_of Enumerator
  end

  it 'overrides #push' do
    subject << 'a b c'
    expect(subject.push('a d')).to equal subject
    expect(subject).to match_array %w(a b c d)
  end

  it 'overrides #unshift' do
    subject << 'a b c'
    expect(subject.unshift('a d')).to equal subject
    expect(subject).to match_array %w(a d b c)
  end

  it 'overrides #values_at' do
    subject << 'a b c'
    expect(subject.values_at(0, 2)).to match_array %w(a c)
    expect(subject.values_at(1)).to be_kind_of described_class
  end

  it 'overrides #|' do
    subject << 'a b c'
    expect(subject | 'b c d').to match_array %w(a b c d)
    expect(subject | 'b c d').to be_kind_of described_class
  end

  {
    :'<=>' => [%w(b c d e)],
    :== => [%w(b c d e)],
    at: [1],
    count: [],
    count: ['a'],
    delete_at: [1],
    fetch: [1],
    hash: [],
    inspect: [],
    to_s: [],
    join: ['-'],
    length: [],
    size: [],
    take: [2],
    to_a: [],
  }.each do |m, args|
    it "passes through ##{m}" do
      a = %w(a b c d)
      subject << a
      expect(subject.send(m, *args)).to eq a.send(m, *args)
    end
  end

  it 'passes through #empty?' do
    expect(subject.empty?).to be_true
  end

  it 'resticts unusefull methods' do
    %i(
      * []= assoc bsearch combination compact compact! fill flatten flatten!
      insert pack permutation product rassoc repeated_combination rotate
      repeated_permutation reverse reverse! reverse_each sample rotate! shuffle
      shuffle! sort sort! sort_by! transpose uniq uniq! zip flat_map max max_by
      min min_by minmax minmax_by
    ).each do |m|
      expect { subject.send(m) }.to raise_error
    end
  end

  it 'provides #to_html' do
    subject << [:a, :b, :c]
    expect(subject.to_html).to eq 'a b c'
  end
end
