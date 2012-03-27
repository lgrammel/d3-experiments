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
    data = resolve(json, "query.results.item");
    transform = function(earthquake) {
      var d;
      d = map.locationPoint({
        lat: earthquake.lat,
        lon: earthquake.long
      });
      return "translate(" + d.x + "," + d.y + ")";
    };
    layer = d3.select("#map svg").insert("svg:g", ".compass");
    marker = layer.selectAll("g").data(data).enter().append("svg:g").attr("transform", transform);
    color = d3.interpolateRgb("#a00", "#f00");
    marker.append("svg:circle").attr("class", "earthquake").attr("r", 4.5).attr("fill", function(d) {
      return color(d.subject[0] / 10);
    }).text(function(d) {
      return "test";
    }).append("svg:title").text(function(d) {
      return "test";
    });
    map.on("move", function() {
      return layer.selectAll("g").attr("transform", transform);
    });
    $('.earthquake').tipsy({
      gravity: 'w'
    });
    return $('.earthquake title').parent().tipsy({
      gravity: 'sw',
      title: function() {
        return $(_this).find('title').text();
      }
    });
  };

  map.add(po.compass().pan("none"));

  (function() {
    return d3.json("http://query.yahooapis.com/v1/public/yql?q=use%20%22http%3A%2F%2Fearthquake.usgs.gov%2Fearthquakes%2Fcatalogs%2Feqs7day-M2.5.xml%22%3B%20select%20*%20from%20rss%20where%20url%3D%22http%3A%2F%2Fearthquake.usgs.gov%2Fearthquakes%2Fcatalogs%2Feqs7day-M2.5.xml%22%3B&format=json&diagnostics=true", resultHandler);
  })();

}).call(this);
