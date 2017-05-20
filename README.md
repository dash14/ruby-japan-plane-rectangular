# Japan Plane Rectangular

Conversion between world geodetic system and Japan plane rectangular coordinate system.

世界測地系と日本平面直角座標系との変換

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'japan_plane_rectangular'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install japan_plane_rectangular

## Usage

```ruby
require 'japan_plane_rectangular'

# TokyoTower
latlon = [35.658596, 139.745403]

# Lat, Lon -> X, Y
xy = JapanPlaneRectangular.to_xy(latlon, 9)
p xy # [-37873.418395058005, -7961.358270500216]

# X, Y -> Lat, Lon
latlon = JapanPlaneRectangular.to_latlon(xy, 9)
p latlon # [35.658596, 139.745403]

# Get nearest zone number by Lat, Lon
zone = JapanPlaneRectangular.nearest_zone(latlon)
p zone # 9
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dash14/ruby-japan-plane-rectangular.
