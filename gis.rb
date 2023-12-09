#!/usr/bin/env ruby

class Track #track object with segments and name
  attr_reader :segments, :name
  def initialize(segments, name=nil) #name is optional
    @name = name
    @segments =[]
    segments.each do |s|
      append_segment(s)
    end
  end

  def append_segment(s) #adds a TrackSegment object to the segments array from a list of points
    @segments.append(TrackSegment.new(s))
  end

  def get_json() #formats the object data to JSON
    j = '{"type": "Feature", '
    if @name != nil   
      j+= '"properties": {"title": "' + @name + '"},'
    end
    j += '"geometry": {"type": "MultiLineString","coordinates": ['
    @segments.each_with_index do |s, index|   #looping through the segments array
      if index > 0
        j += ","
      end
      j += '['
      tsj = ''      #creating a temp string to hold the coordinates
      s.coordinates.each do |c|     #looping through the coordinates array of each segment
        if tsj != ''
          tsj += ','
        end
        tsj += "[#{c.lon},#{c.lat}"   #adding the lon and lat to the temp string
        if c.ele != nil
          tsj += ",#{c.ele}"        #adding the ele if it is not nil
        end
        tsj += ']'
      end
      j+=tsj  #adding the temp string to the json string
      j+=']'
    end
    j + ']}}'
  end
end

class TrackSegment    #track segment object with coordinates
  attr_reader :coordinates
  def initialize(coordinates)
    coordinates.each do |c|   #verifying that all passed coordinates are point objects
      if c.class != Point
        raise "Not a point"
      end
    end
    @coordinates = coordinates
  end
end

class Point   #point object with lon, lat, and ele

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil) #ele is optional
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint  #waypoint object with lon, lat, ele, name, and type
attr_reader :point, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)   #ele, name, and type are all optional
    @point = Point.new(lon, lat, ele) #creating a point object to hold the lon, lat, and ele
    @name = name
    @type = type
  end

  def get_json() #formats the object data to JSON
    j = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    j += "[#{@point.lon},#{@point.lat}"
    if @point.ele != nil
      j += ",#{@point.ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          j += ','
        end
        j += '"icon": "' + @type + '"'  # type is the icon
      end
      j += '}'
    end
    j += "}"
    return j
  end
end

class World
def initialize(name, features) #changes teh name things to features
  @name = name
  @features = features
end
  def add_feature(f) #changed .append to add f insterad of t
    @features.append(f)
  end

  def get_json() #removed the indent variable
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        s+= f.get_json()  #changed this to get_json, because we should not have to check the object type, it should just use polymorphism
    end
    s + "]}"
  end
end

def main()
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

  world = World.new("My Data", [w, w2, t, t2])

  puts world.get_json()
end

if File.identical?(__FILE__, $0)
  main()
end

