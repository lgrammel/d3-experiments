resolve = (value,path) ->
  for element in path.split(".")
    value = value[element]
  value

# Code based on Polymaps example from Mike Bostock http://bl.ocks.org/899670
po = org.polymaps
map = po.map().container(d3.select("#map").append("svg:svg").node())
        .zoom(2)
        .center({lat: 40, lon: 0})
        .add(po.drag())
        .add(po.wheel().smooth(false))
        .add(po.dblclick())
        .add(po.arrow())

# background tiles
map.add(po.image().url(po.url("http://tile.stamen.com/toner/{Z}/{X}/{Y}.png")))

resultHandler = (json) ->
  data = resolve(json, "feed.entry")

  transform = (earthquake) ->
    latlng = earthquake.gsx$coordinates.$t.split("/") # coordinates are in format 'lat/lng'
    d = map.locationPoint({lat: latlng[0], lon: latlng[1]})
    "translate(" + d.x + "," + d.y + ")"

  # Insert our layer beneath the compass.
  layer = d3.select("#map svg").insert("svg:g", ".compass");

  marker = layer.selectAll("g").data(data)
                .enter().append("svg:g")
                .attr("transform", transform)
                .attr("class", "earthquake")

  color = d3.interpolateRgb("#000","#f00")

  marker.append("svg:circle")
        .attr("r", 4.5)
        .attr("fill", (d) => color(d.gsx$magnitude.$t / 10)) # color by magnitude (brighter = stronger)

  marker.append("svg:text")
        .attr("x", 7)
        .attr("dy", ".31em")
        .attr("stroke", "red")
        .text((d) ->  d.gsx$title.$t ) # title if exists

  map.on("move", ->
    layer.selectAll("g").attr("transform", transform)
  )

map.add(po.compass().pan("none"))

do ->
  d3.json("https://spreadsheets.google.com/feeds/list/tYFwOmgNfJe1WWHR9OcGnCw/od6/public/values?alt=json", resultHandler)
  # Spredsheet can be viewed at
  # https://docs.google.com/spreadsheet/ccc?key=0AgNAl7-WtHbcdFlGd09tZ05mSmUxV1dIUjlPY0duQ3c&authkey=CITGzqML