# frozen_string_literal: true

require 'japan_plane_rectangular/constants'

module JapanPlaneRectangular
  module Functions
    include JapanPlaneRectangular::Constants

    # Find nearest zone number by [Latitude, Longitude]
    # @param [Array<Float>] latlon [Latitude, Longitude]
    # @return [Integer] zone number (1~19)
    def nearest_zone(latlon)
      min_index = 0
      min_val = Float::MAX
      ORIGINS.each_with_index do |origin, i|
        xy1 = to_xy(latlon, 7)
        xy2 = to_xy(origin, 7)
        d = distance(xy1, xy2)
        if d < min_val
          min_index = i
          min_val = d
        end
      end
      min_index + 1 # zone number
    end

    # Convert to XY from latlon in zone
    # @param [Array<Float>] latlon [latitude, longitude]
    # @param [Integer] zone zone number (1~19)
    # @return [Array<Float>] [x, y]
    def to_xy(point, zone)
      raise ArgumentError, 'Invalid zone number' unless 1 <= zone && zone <= 19
      origin_point = ORIGINS[zone - 1]

      phi0 = to_radian(origin_point[0])
      lamda0 = to_radian(origin_point[1])

      phi1 = to_radian(point[0])
      lamda1 = to_radian(point[1])

      s0 = meridian_arc_length(phi0)
      s1 = meridian_arc_length(phi1)

      ut = GRS80_ER / Math.sqrt(1.0 - ECCENTRICITY**2.0 * Math.sin(phi1)**2.0)
      conp = Math.cos(phi1)
      t1 = Math.tan(phi1)
      dlamda = lamda1 - lamda0
      eta2 = (ECCENTRICITY**2.0 / (1.0 - ECCENTRICITY**2.0)) * conp**2.0

      v1 = 5.0 - t1**2.0 + 9.0 * eta2 + 4.0 * eta2**2.0
      v2 = -61.0 + 58.0 * t1**2.0 - t1**4.0 - 270.0 * eta2 + 330.0 * t1**2.0 * eta2
      v3 = -1385.0 + 3111.0 * t1**2.0 - 543.0 * t1**4.0 + t1**6.0

      x = ((s1 - s0) + ut * conp**2.0 * t1 * dlamda**2.0 / 2.0 +
          ut * conp**4.0 * t1 * v1 * dlamda**4.0 / 24.0 -
          ut * conp**6.0 * t1 * v2 * dlamda**6.0 / 720.0 -
          ut * conp**8.0 * t1 * v3 * dlamda**8.0 / 40320.0) * M0

      v1 = -1.0 + t1**2.0 - eta2
      v2 = -5.0 + 18.0 * t1**2.0 - t1**4.0 - 14.0 * eta2 + 58.0 * t1**2.0 * eta2
      v3 = -61.0 + 479.0 * t1**2.0 - 179.0 * t1**4.0 + t1**6.0

      y = (ut * conp * dlamda -
          ut * conp**3.0 * v1 * dlamda**3.0 / 6.0 -
          ut * conp**5.0 * v2 * dlamda**5.0 / 120.0 -
          ut * conp**7.0 * v3 * dlamda**7.0 / 5040.0) * M0

      [x, y]
    end

    # Convert to latlon from XY in zone
    # @param [Array<Float>] xy [x, y]
    # @param [Integer] zone zone number (1~19)
    # @return [Array<Float>] [latitude, longitude]
    def to_latlon(xy, zone)
      raise ArgumentError, 'Invalid zone number' unless 1 <= zone && zone <= 19
      origin_point = ORIGINS[zone - 1]
      (x, y) = xy

      phi0 = to_radian(origin_point[0])
      lamda0 = to_radian(origin_point[1])

      phi1 = perpendicular(x, phi0)

      ut = GRS80_ER / Math.sqrt(1.0 - ECCENTRICITY**2.0 * Math.sin(phi1)**2.0)
      conp = Math.cos(phi1)
      t1 = Math.tan(phi1)
      eta2 = (ECCENTRICITY**2.0 / (1.0 - ECCENTRICITY**2.0)) * conp**2.0

      yy = y / M0
      v1 = 1.0 + eta2
      v2 = 5.0 + 3.0 * t1**2.0 + 6.0 * eta2 - 6.0 * t1**2.0 * eta2 - 3.0 * eta2**2.0 - 9.0 * t1**2.0 * eta2**2.0
      v3 = 61.0 + 90.0 * t1**2.0 + 45.0 * t1**4.0 + 107.0 * eta2 - 162.0 * t1**2.0 * eta2 - 45.0 * t1**4.0 * eta2
      v4 = 1385.0 + 3633.0 * t1**2.0 + 4095.0 * t1**4.0 + 1575.0 * t1**6.0

      phir = -(v1 / (2.0 * ut**2.0)) * yy**2.0
      phir += (v2 / (24.0 * ut**4.0)) * yy**4.0
      phir -= (v3 / (720.0 * ut**6.0)) * yy**6.0
      phir += (v4 / (40320.0 * ut**8.0)) * yy**8.0
      phir *= t1
      phir += phi1
      phir = to_degree(phir)

      v1 = ut * conp
      v2 = 1.0 + 2.0 * t1**2.0 + eta2
      v3 = 5.0 + 28.0 * t1**2.0 + 24.0 * t1**4.0 + 6.0 * eta2 + 8.0 * t1**2.0 * eta2
      v4 = 61.0 + 662.0 * t1**2.0 + 1320.0 * t1**4.0 + 720.0 * t1**6.0

      lamdar = (1.0 / v1) * yy
      lamdar -= (v2 / (6.0 * ut**2.0 * v1)) * yy**3.0
      lamdar += (v3 / (120.0 * ut**4.0 * v1)) * yy**5.0
      lamdar -= (v4 / (5040.0 * ut**6.0 * v1)) * yy**7.0
      lamdar += lamda0

      lamdar = to_degree(lamdar)

      [phir, lamdar]
    end

    private

    def distance(p1, p2)
      (x1, y1) = p1
      (x2, y2) = p2
      Math.sqrt((x2 - x1)**2.0 + (y2 - y1)**2.0)
    end

    def to_radian(degree)
      degree * Math::PI / 180.0
    end

    def to_degree(radian)
      radian * 180.0 / Math::PI
    end

    def perpendicular(x, phi0)
      s0 = meridian_arc_length(phi0)
      m = s0 + x / M0
      cnt = 0
      phin = phi0
      e2 = ECCENTRICITY**2.0
      phi0 = phin

      loop do
        cnt += 1
        phi0 = phin
        sn = meridian_arc_length(phin)
        v1 = 2.0 * (sn - m) * ((1.0 - e2 * Math.sin(phin)**2.0)**1.5)
        v2 = 3.0 * e2 * (sn - m) * Math.sin(phin) * Math.cos(phin) * Math.sqrt(1.0 - e2 * Math.sin(phin)**2.0) - 2.0 * GRS80_ER * (1.0 - e2)
        phin += v1 / v2
        break if ((phin - phi0).abs < 0.00000000000001) || cnt > 100
      end
      phin
    end

    def meridian_arc_length(lat_rad)
      e0 = ECCENTRICITY
      e2 = e0**2.0
      e4 = e0**4.0
      e6 = e0**6.0
      e8 = e0**8.0
      e10 = e0**10.0
      e12 = e0**12.0
      e14 = e0**14.0
      e16 = e0**16.0

      a = 1.0 + 3.0 / 4.0 * e2 + 45.0 / 64.0 * e4 + 175.0 / 256.0 * e6 + 11025.0 / 16384.0 * e8 + 43659.0 / 65536.0 * e10 + 693693.0 / 1048576.0 * e12 + 19324305.0 / 29360128.0 * e14 + 4927697775.0 / 7516192768.0 * e16
      b = 3.0 / 4.0 * e2 + 15.0 / 16.0 * e4 + 525.0 / 512.0 * e6 + 2205.0 / 2048.0 * e8 + 72765.0 / 65536.0 * e10 + 297297.0 / 262144.0 * e12 + 135270135.0 / 117440512.0 * e14 + 547521975.0 / 469762048.0 * e16
      c = 15.0 / 64.0 * e4 + 105.0 / 256.0 * e6 + 2205.0 / 4096.0 * e8 + 10395.0 / 16384.0 * e10 + 1486485.0 / 2097152.0 * e12 + 45090045.0 / 58720256.0 * e14 + 766530765.0 / 939524096.0 * e16
      d = 35.0 / 512.0 * e6 + 315.0 / 2048.0 * e8 + 31185.0 / 131072.0 * e10 + 165165.0 / 524288.0 * e12 + 45090045.0 / 117440512.0 * e14 + 209053845.0 / 469762048.0 * e16
      e = 315.0 / 16384.0 * e8 + 3465.0 / 65536.0 * e10 + 99099.0 / 1048576.0 * e12 + 4099095.0 / 29360128.0 * e14 + 348423075.0 / 1879048192.0 * e16
      f = 693.0 / 131072 * e10 + 9009.0 / 524288.0 * e12 + 4099095.0 / 117440512.0 * e14 + 26801775.0 / 469762048.0 * e16
      g = 3003 / 2097152.0 * e12 + 315315.0 / 58720256.0 * e14 + 11486475.0 / 939524096.0 * e16
      h = 45045.0 / 117440512.0 * e14 + 765765.0 / 469762048.0 * e16
      i = 765765.0 / 7516192768.0 * e16

      meridian = GRS80_ER * (1.0 - e2) * (a * lat_rad -
                  b * Math.sin(lat_rad * 2.0) / 2.0 +
                  c * Math.sin(lat_rad * 4.0) / 4.0 -
                  d * Math.sin(lat_rad * 6.0) / 6.0 +
                  e * Math.sin(lat_rad * 8.0) / 8.0 -
                  f * Math.sin(lat_rad * 10.0) / 10.0 +
                  g * Math.sin(lat_rad * 12.0) / 12.0 -
                  h * Math.sin(lat_rad * 14.0) / 14.0 +
                  i * Math.sin(lat_rad * 16.0) / 16.0)
      meridian
    end
  end
end
