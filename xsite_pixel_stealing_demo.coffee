if Meteor.isClient
  Template.attack_iframe.created = ->
    # prime numbers to avoid patterns (hopefully?)
    test_intervals = [1, 11, 51, 101, 151, 199, 307, 401, 499, 701, 997, 1999, 3001, 5003]
    test_duration = 30*1000
    mid_test_delay = 5*1000
    test_urls = ["http://edition.cnn.com/", "http://getbootstrap.com/"]
    curr_test_times = [0, 0]
    iframe_id = "#attack-iframe"

    toggle_blur = ->
      frame = $ iframe_id
      frame.toggleClass 'filter'

    stop_test = (test_num, test_id) ->
      clearInterval test_id
      curr_test_times[test_num] = Template.fps_counter.fps()
      rev_i = (test_num + 1) % 2
      document.getElementById("attack-iframe").src = test_urls[rev_i] # 0 or 1
      setTimeout Template.fps_counter.start, mid_test_delay

    start_test = (i) ->
      # run the test for iframe 1
      test_id = setInterval toggle_blur, test_intervals[i]

      # stop the test after duration
      setTimeout stop_test, test_duration, 0, test_id

      # start the next test after duration + delay
      next_test = ->
        test_id = setInterval toggle_blur, test_intervals[i]
        # stop the test after duration
        setTimeout stop_test, test_duration, 1, test_id
      setTimeout next_test, test_duration + mid_test_delay

      # report findings after duration + delay (twice), and start the next test
      wrap_up = ->
        console.log "Test \##{i}: [#{test_intervals[i]}ms]"
        console.log "\t#{test_urls[0]}: #{curr_test_times[0]}"
        console.log "\t#{test_urls[1]}: #{curr_test_times[1]}"
        console.log "\tDelta: #{curr_test_times[1] - curr_test_times[0]}\n\n"
        if i < test_intervals.length
          start_test i + 1
        else
          console.log "Finished all tests"
      setTimeout wrap_up, 2*(test_duration + mid_test_delay)

    start_suite = -> start_test 0
    # short delay for page to load
    setTimeout start_suite, mid_test_delay


  Template.fps_counter.results = []

  Template.fps_counter.start = ->
    Template.fps_counter.start_time = Date.now()
    Template.fps_counter.total_frames = 0
    if not Template.fps_counter.is_running
      Template.fps_counter.is_running = true
      Template.fps_counter.step()
    # prime number, again
    setInterval Template.fps_counter.update_fps, 71

  Template.fps_counter.created = ->
    setTimeout Template.fps_counter.start, 5000

  Template.fps_counter.update_fps = ->
    Session.set "curr_time", Date.now()

  Template.fps_counter.step = ->
    Template.fps_counter.total_frames += 1
    requestAnimationFrame Template.fps_counter.step

  Template.fps_counter.fps = ->
    elapsed = Session.get("curr_time") - Template.fps_counter.start_time
    total_frames = Template.fps_counter.total_frames
    ((total_frames / elapsed) * 1000.0).toFixed(2)

if Meteor.isServer
  Meteor.startup ->
  # code to run on server at startup