# Rspec Mandelbrot set

To create the Mandelbrot set, use:

    rspec -o mandelbrot.txt
    head -n 1 mandelbrot.txt

I have not worked out how to get rspec to only show the progress and suppress
the information about failed tests (why would anyone want to do that, eh?) and
so the best way to view it is to output to a file and then view just the first
line. To view correctly your terminal needs to be the correct width. By default
this is 121 characters but it will change if you change the resolution.
