Array::waitForEach = (callback, allDone, thisArg) ->
  remaining = @length
  unless remaining
    allDone()
  else
    @forEach ((element, index, array) ->
      done = false
      callback.call thisArg, element, (->
        throw "Called `done` multiple times for element " + index  if done
        done = true
        allDone() unless --remaining
      ), index, array
    ), thisArg
