require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, nil, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, nil, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)
  end

  def test_tracks
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)

    t = Track.new([ts3], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
  end

  def test_world
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    t2 = Track.new([ts3], "track 2")

    w = World.new("My Data", [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.get_json)
    assert_equal(expected, result)
  end

  def test_append_feature #testing that the features are being added to the world and printing correctly
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    t2 = Track.new([ts3], "track 2")

    w = World.new("My Data", [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.get_json)
    assert_equal(expected, result)

    w3 = Waypoint.new(-110, 40, 20, "gym", "dot")
    w.add_feature(w3)
    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}, {"type": "Feature","properties": {"title": "gym","icon": "dot"},"geometry": {"type": "Point","coordinates": [-110,40,20]}}]}' )
    result = JSON.parse(w.get_json)
    assert_equal(expected, result)
  end

  def test_append_segment
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]
    t = Track.new([ts1, ts2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
    ts3 = [
      Point.new(-101, 32),
      Point.new(-170, 50),
    ]
    t.append_segment(ts3)
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]],[[-101,32],[-170,50]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
  end

  def test_not_a_point
    assert_raise("Not a point") { #if a track is made where one of the points in not a point object, raise an error
      t1 = Track.new([Point.new(-122, 45), [121,12], Point.new(-121, 46)], "track 1")
    }
  end
end



