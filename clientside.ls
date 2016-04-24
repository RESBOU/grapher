# * Require
require! {
  leshdash: { mapValues, map, pick, each, assign, flattenDeep, flatten }
  bluebird: p
  'socket.io-client': io
  d3
  moment
}

parseDates = (data) ->
  map data, (layer) ->
    map layer, (event) ->
      assign {}, event, mapValues pick(event, 'start','end'), (value) -> new moment(value).toDate()

# * Draw
draw = (data) ->
  console.log "DRAW", flatten data
  
  return
  
  margin = {top: 30, right: 20, bottom: 30, left: 50}
  width = 600 - margin.left - margin.right
  height = 270 - margin.top - margin.bottom

  parseDate = d3.time.format("%d-%b-%y").parse;

  x = d3.time.scale().range([0, width]);
  y = d3.scale.linear().range([height, 0]);

  xAxis = d3.svg.axis().scale(x)
  .orient("bottom").ticks(5);

  yAxis = d3.svg.axis().scale(y)
  .orient("left").ticks(5);

  valueline = d3.svg.line()
    .x (d) -> x d.date
    .y (d) -> y d.close
    
  svg = d3.select("body")
    .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
    .append("g")
        .attr("transform", 
              "translate(" + margin.left + "," + margin.top + ")")

    each data, (d) -> 
      d.date = parseDate(d.date);
      d.close = + d.close;
    
    x.domain d3.min flattenDeep(data), (d) -> d.date
    y.domain [0, data.length ]

    svg.append("path")
      .attr("class", "line")
      .attr("d", valueline(data))

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)

# * Socket
socket = io window.location.host
socket.on 'connect', -> console.log 'connected'
socket.on 'update', -> if it is data.id then window.location.reload!
socket.on 'reconnect', -> window.location.reload!

# * Init
data.data
  |> parseDates
  |> draw 
