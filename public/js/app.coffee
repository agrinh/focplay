socket = io()

# Start playing
window.play = ->
  socket.emit 'start'

# On playing
socket.on 'playing', ->
  $('circle:not(.middle-foc)')
    .velocity(rotateZ: "360", {duration: 8000, loop: true})

# On stopped
socket.on 'stopped', ->
  $('circle:not(.middle-foc)').velocity('stop')

svg = d3.select('#playbox')

# Define scales for the svg coordinate system
xScale = d3.scale.linear().domain([-480, 480]).range([0, 960])
yScale = d3.scale.linear().domain([-320, 320]).range([0, 640])

# Create foc logo circles
R = 250
r = 30
angles = ((2/7)*Math.PI*n for n in [0..6])
circle_data = (for angle in angles
               x: xScale(R*Math.cos(angle))
               y: yScale(R*Math.sin(angle)))

# group surrounding circles
group = svg.append('g')
circles = group
  .selectAll('circle')
  .data(circle_data)
  .enter()
  .append('circle')

circles
  .attr('cx', (d) -> d.x)
  .attr('cy', (d) -> d.y)
  .attr('r', (d) -> r)
  .style('fill', 'red')
  .attr('opacity', 0)
  .style('transform-origin', xScale(0) + 'px ' + yScale(0) + 'px')

middle = svg.append('circle')
  .attr('cx', xScale(0))
  .attr('cy', yScale(0))
  .attr('r', R*0.4)
  .style('fill', 'red')
  .classed('middle-foc', true)
  .attr('opacity', 0)
  .on('click', play)
  .classed('glyphicon glyphicon-play-circle', true)

# intro animations
$('.middle-foc').velocity opacity: 1, duration: 1000
$('circle').velocity opacity: 1, duration: 3000
