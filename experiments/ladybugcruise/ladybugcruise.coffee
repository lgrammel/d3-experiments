resolve = (value,path) ->
  for element in path.split(".")
    value = value[element]
  value

# Code based on Polymaps example from Mike Bostock http://bl.ocks.org/899670
po = org.polymaps
map = po.map().container(d3.select("#map").append("svg:svg").node())
        .zoom(4)
        .center({lat: 5, lon: -130})
        .add(po.drag())
        .add(po.wheel().smooth(false))
        .add(po.dblclick())
        .add(po.arrow())

# background tiles from Stamen http://maps.stamen.com
map.add(po.image().url(po.url("http://tile.stamen.com/watercolor/{Z}/{X}/{Y}.jpg")))

# generic transform function
transform = (location) ->
  d = map.locationPoint(location)
  "translate(" + d.x + "," + d.y + ")"

# 3 reference points
referencePoints = [
  {lat: 22.889722, lon: -109.915556, label: "Cabo San Lucas", wikipedia: "http://en.wikipedia.org/wiki/Cabo_San_Lucas"},
  {lat: 18.366667, lon: -114.733333, label: "Clarion Island", wikipedia: "http://en.wikipedia.org/wiki/Clarion_Island"},
  {lat: -9.75, lon: -139, label: "Hiva Oa in the Marquesas", wikipedia: "http://en.wikipedia.org/wiki/Hiva_Oa"}
]
referenceLayer = d3.select("#map svg").insert("svg:g");
marker = referenceLayer.selectAll("g").data(referencePoints).enter().append("g").attr("transform", transform)

marker.append("circle")
  .attr("class", "destination")
  .attr("r", 10)
  .attr("fill", "#5F9EA0")
  .attr("text", (d) => d.label)
  .on("click", (d) => window.open(d.wikipedia ,"_blank"))

map.on("move", ->
    referenceLayer.selectAll("g").attr("transform", transform)
)

# daily positions
resultHandler = (json) ->
  data = resolve(json, "feed.entry").map((location) =>
    {
      lat: resolve(location, "gsx$lat.$t"),
      lon: resolve(location, "gsx$lng.$t"),
      title: resolve(location, "gsx$title.$t"),
      day: resolve(location, "gsx$day.$t"),
      blogpost: resolve(location, "gsx$blogpost.$t")
    }
  );

  # create line
  line = d3.svg.line().x((d) => d.x).y((d) => d.y ).interpolate("cardinal")
  mappedLine = (d) =>
    line(data.map((d) => map.locationPoint(d)))
  lineLayer = d3.select("#map svg").insert("svg:g");
  lineLayer.selectAll("g").data([data]).enter()
    .append("path")
    .attr("fill", "none")
    .attr("stroke", "#666")
    .attr("stroke-width", "4")
    .attr("d", (d) => mappedLine(d))

  map.on("move", ->
      lineLayer.selectAll("path").attr("d",  (d) => mappedLine(d));
  )

  # Insert our layer beneath the compass.
  layer = d3.select("#map svg").insert("svg:g");

  marker = layer.selectAll("g").data(data).enter().append("g")
                .attr("transform", transform)

  marker.append("circle")
        .attr("class", "location")
        .attr("r", 4.5)
        .attr("fill", "#FF7F50")
        .attr("text", (d) => d.day + ": <b>" + d.title + "</b>")
        .on("click", (d) => window.open(d.blogpost ,"_blank"))

  map.on("move", ->
    layer.selectAll("g").attr("transform", transform)
  )

  $(".location,.destination").qtip({
    content: {
      attr: 'text'
    }
  })

map.add(po.compass().pan("none"))

do ->
  d3.json("https://spreadsheets.google.com/feeds/list/t3ptjGRbr63okgAiqSc12tA/od6/public/values?alt=json", resultHandler)
  # Spreadsheet: https://docs.google.com/spreadsheet/ccc?key=0AgNAl7-WtHbcdDNwdGpHUmJyNjNva2dBaXFTYzEydEE#gid=0