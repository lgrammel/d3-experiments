(function() {
  var map, po, resolve, resultHandler;

  resolve = function(value, path) {
    var element, _i, _len, _ref;
    _ref = path.split(".");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      element = _ref[_i];
      value = value[element];
    }
    return value;
  };

  po = org.polymaps;

  map = po.map().container(d3.select("#map").append("svg:svg").node()).zoom(2).center({
    lat: 40,
    lon: 0
  }).add(po.drag()).add(po.wheel().smooth(false)).add(po.dblclick()).add(po.arrow());

  map.add(po.image().url(po.url("http://tile.stamen.com/toner/{Z}/{X}/{Y}.png")));

  resultHandler = function(json) {
    var color, data, layer, marker, transform,
      _this = this;
    data = resolve(json, "feed.entry");
    transform = function(earthquake) {
      var d, latlng;
      latlng = earthquake.gsx$coordinates.$t.split("/");
      d = map.locationPoint({
        lat: latlng[0],
        lon: latlng[1]
      });
      return "translate(" + d.x + "," + d.y + ")";
    };
    layer = d3.select("#map svg").insert("svg:g", ".compass");
    marker = layer.selectAll("g").data(data).enter().append("svg:g").attr("transform", transform).attr("class", "earthquake");
    color = d3.interpolateRgb("#000", "#f00");
    marker.append("svg:circle").attr("r", 4.5).attr("fill", function(d) {
      return color(d.gsx$magnitude.$t / 10);
    });
    marker.append("svg:text").attr("x", 7).attr("dy", ".31em").attr("stroke", "red").text(function(d) {
      return d.gsx$title.$t;
    });
    return map.on("move", function() {
      return layer.selectAll("g").attr("transform", transform);
    });
  };

  map.add(po.compass().pan("none"));

  (function() {
    return d3.json("https://spreadsheets.google.com/feeds/list/tYFwOmgNfJe1WWHR9OcGnCw/od6/public/values?alt=json", resultHandler);
  })();

}).call(this);
