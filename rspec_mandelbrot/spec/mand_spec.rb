RSpec.describe 'Mandelbrot set' do
  after(:all) { sleep 50 }

  let(:iterations) { 500 }

  # Dimensions are actually 121x81.
  # Think fence-posts.
  width = 120
  height = 80

  i_0 = -1
  i_1 = 1
  r_0 = -2
  r_1 = 1

  i_step = (i_1 - i_0).to_f/height
  r_step = (r_1 - r_0).to_f/width

  (i_0..i_1).step(i_step) do |i|
    (r_0..r_1).step(r_step) do |r|
      context "with c = #{r} - #{i}i" do
        let(:c) { r - i*1i }

        it do
          iterations.times.inject(0) do |x|
            (x**2 + c).tap { |y| expect(y).to be_within(2).of(0) }
          end
        end
      end
    end
  end
end
