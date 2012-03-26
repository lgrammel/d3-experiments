resolve = (value,path) ->
  for element in path.split(".")
    value = value[element]
  value

# Code based on Google maps example from Mike Bostock http://bl.ocks.org/899711
resultHandler = (result) ->
  map = new google.maps.Map(d3.select("#map").node(), {
    zoom: 2,
    center: new google.maps.LatLng(37.76487, -122.41948),
    mapTypeId: google.maps.MapTypeId.TERRAIN
  })

  # feed.entry gives all rows (except for first one) for google spreadsheet
  # column values for row are contained in gsx$COLUMNNAME.$t
  data = resolve(result, "feed.entry")

  overlay = new google.maps.OverlayView
  overlay.onAdd = ->
    layer = d3.select(this.getPanes().overlayLayer).append("div").attr("class", "earthquake")
    overlay.draw = ->
      projection = this.getProjection()
      padding = 10

      transform = (earthquake) ->
        latlng = earthquake.gsx$coordinates.$t.split("/") # coordinates are in format 'lat/lng'
        location = projection.fromLatLngToDivPixel(new google.maps.LatLng(latlng[0], latlng[1]))
        d3.select(this)
          .style("left", (location.x - padding) + "px")
          .style("top", (location.y - padding) + "px")

      color = d3.interpolateRgb("#000","#0f0")

      marker = layer.selectAll("svg").data(data).each(transform)
        .enter().append("svg:svg").each(transform).attr("class", "marker")

      marker.append("svg:circle")
        .attr("r", 4.5)
        .attr("cx", padding)
        .attr("cy", padding)
        .attr("fill", (d) => color(d.gsx$magnitude.$t / 10)) # color by magnitude (brighter = stronger)

      marker.append("svg:text")
        .attr("x", padding + 7)
        .attr("y", padding)
        .attr("dy", ".31em")
        .text((d) ->  d.gsx$title.$t ) # title if exists

  overlay.setMap(map)

do ->
  d3.json("https://spreadsheets.google.com/feeds/list/tYFwOmgNfJe1WWHR9OcGnCw/od6/public/values?alt=json", resultHandler)
  # Spredsheet can be viewed at
  # https://docs.google.com/spreadsheet/ccc?key=0AgNAl7-WtHbcdFlGd09tZ05mSmUxV1dIUjlPY0duQ3c&authkey=CITGzqML