describe 'Mandelbrot set' do

  (-1..1).step(0.025) do |i|
    (-2..1).step(0.025) do |r|

      it 'converges' do
        c = Complex(r, -i)
        x = Complex(0, 0)
        50.times do
          x = x**2 + c
          expect(x.magnitude).to be < 4
        end
      end

    end
  end

end
