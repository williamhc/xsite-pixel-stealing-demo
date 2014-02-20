if Meteor.isClient
  Session.set "total_frames", 0

  Template.fps_counter.created = ->
    Template.fps_counter.startTime = Date.now()
    setInterval Template.fps_counter.reset, 100
    Template.fps_counter.step()

  Template.fps_counter.reset = ->
    Session.set("curr_time", Date.now())

  Template.fps_counter.step = ->
    Template.fps_counter.total_frames += 1
    requestAnimationFrame Template.fps_counter.step

  Template.fps_counter.fps = ->
    elapsed = Session.get("curr_time")
    total_frames = Template.fps_counter.total_frames
    Template.fps_counter.total_frames = 0
    ((total_frames / 100) * 1000).toFixed(2)

if Meteor.isServer
  Meteor.startup ->
  # code to run on server at startup