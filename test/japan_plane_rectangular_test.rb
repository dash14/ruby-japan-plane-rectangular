require "test_helper"

class JapanPlaneRectangularTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::JapanPlaneRectangular::VERSION
  end

  # Reference:
  # - http://vldb.gsi.go.jp/sokuchi/surveycalc/surveycalc/bl2xyf.html
  # - http://vldb.gsi.go.jp/sokuchi/surveycalc/surveycalc/xy2blf.html

  def test_zone_9_tokyo
    lat = 36.103774791666666
    lon = 140.08785504166664
    x = 11543.6883
    y = 22916.2436

    assert_xy_zone(lat, lon, x, y, 9)
  end

  def test_zone_9_tokyo_tower
    lat = 35.658596
    lon = 139.745403
    x = -37873.4184
    y = -7961.3583

    assert_xy_zone(lat, lon, x, y, 9)
  end

  def test_zone_1_nagasaki
    lat = 32.890270
    lon = 129.013751
    x = -12063.3920
    y = -45493.3744

    assert_xy_zone(lat, lon, x, y, 1)
  end

  def test_zone_13_abashiri
    lat = 44.005905
    lon = 144.270721
    x = 656.2613
    y = 1661.6215

    assert_xy_zone(lat, lon, x, y, 13)
  end

  def assert_xy_zone(lat, lon, expect_x, expect_y, expect_zone)
    zone = JapanPlaneRectangular.nearest_zone([lat, lon])
    assert_equal expect_zone, zone

    (x, y) = JapanPlaneRectangular.to_xy([lat, lon], zone)
    assert_in_delta(expect_x, x)
    assert_in_delta(expect_y, y)

    (lat2, lon2) = JapanPlaneRectangular.to_latlon([x, y], zone)
    assert_in_delta(lat, lat2)
    assert_in_delta(lon, lon2)
  end
end
