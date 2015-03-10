# cgbi_to_png

This Gem allows converting CgBI (Apple's optimized PNG) images into standard PNG images. See http://iphonedevwiki.net/index.php/CgBI_file_format

## Installation

Add this line to your application's Gemfile:

    gem 'cgbi_to_png'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cgbi_to_png

## Usage

    opng = CgBItoPNG::from_file('apple-optimized-image.png')
    opng.unoptimize
    opng.to_file('standard-image.png')

## Limitations

- Currently this Gem only supports 8bit color depth and Color Type '6' (RGB + alpha)
- Interlacing is not supported
- Alpha channel correction is not performed

Taking into account the expected usage of this Gem (viewing iOS optimized icons) these limitations are probably not a problem.

## Contributing

1. Fork it ( http://github.com/jappelbe/cgbi_to_png/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
