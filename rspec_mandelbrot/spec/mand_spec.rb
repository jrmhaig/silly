describe 'Mandelbrot set' do
  after(:all) do
    sleep 50
  end

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
      it "converges with c = #{r} - #{i}i" do
        c = r - i*1i
        x = 0 + 0i

        500.times do
          x = x**2 + c
          expect(x.magnitude).to be < 2
        end
      end
    end
  end
end
