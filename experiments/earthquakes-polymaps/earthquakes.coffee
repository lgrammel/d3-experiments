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

# background tiles from Stamen http://maps.stamen.com
map.add(po.image().url(po.url("http://tile.stamen.com/toner/{Z}/{X}/{Y}.png")))

resultHandler = (json) ->
  data = resolve(json, "query.results.item")

  transform = (earthquake) ->
    d = map.locationPoint({lat: earthquake.lat, lon: earthquake.long})
    "translate(" + d.x + "," + d.y + ")"

  # Insert our layer beneath the compass.
  layer = d3.select("#map svg").insert("svg:g", ".compass");

  marker = layer.selectAll("g").data(data)
                .enter().append("svg:g")
                .attr("transform", transform)
                .attr("class", "earthquake")

  color = d3.interpolateRgb("#a00","#f00")

  marker.append("svg:circle")
        .attr("r", 4.5)
        .attr("fill", (d) => color(d.subject[0] / 10)) # color by magnitude (brighter = stronger)

  marker.append("svg:text")
        .attr("x", 7)
        .attr("dy", ".31em")
        .attr("stroke", "red")

  map.on("move", ->
    layer.selectAll("g").attr("transform", transform)
  )

map.add(po.compass().pan("none"))

do ->
  d3.json("http://query.yahooapis.com/v1/public/yql?q=use%20%22http%3A%2F%2Fearthquake.usgs.gov%2Fearthquakes%2Fcatalogs%2Feqs7day-M2.5.xml%22%3B%20select%20*%20from%20rss%20where%20url%3D%22http%3A%2F%2Fearthquake.usgs.gov%2Fearthquakes%2Fcatalogs%2Feqs7day-M2.5.xml%22%3B&format=json&diagnostics=true", resultHandler)
  # Using YQL to get data from http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M2.5.xml
  # to circumvent cross-origin problems via JSONP