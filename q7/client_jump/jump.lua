jumpWindow = nil
jumpButton = nil

animationEvent = nil

tickTime = 250               -- time (ms) between each animation loop code execution
distancePerTick = 8          -- distance that the button moves per animation loop code execution
buttonSpawnSafezone = 16     -- padding around the window in which the button cannot move or spawn into
titleBarHeight = 32          -- used for avoid spawning the button overlapping the title bar, TODO: there may be a function that gets this dynamically
buttonSpawnXRandomness = 0.2 -- what percentage of the window (from the right edge) can the button spawn in, e.g. 0.2 = button can spawn on the rightmost 20% of the window

-- caches values that stays constant throughout the module's lifetime to avoid repeated queries and computation
buttonWidth = 0
buttonHeight = 0
windowWidth = 0
windowHeight = 0
-- relative to the window's x and y positions, the minimum and maximum offsets to spawn buttons
minButtonYSpawnOffset = 0
maxButtonYSpawnOffset = 0
minButtonXSpawnOffset = 0
maxButtonXSpawnOffset = 0

function init()
  connect(g_game, {})

  -- create window on init and get button reference
  jumpWindow = g_ui.displayUI('jump')
  jumpButton = jumpWindow:getChildById('buttonJump')

  -- compute and cache constant numeric values
  buttonWidth = jumpButton:getWidth()
  buttonHeight = jumpButton:getHeight()
  windowWidth = jumpWindow:getWidth()
  windowHeight = jumpWindow:getHeight()
  minButtonYSpawnOffset = titleBarHeight + buttonSpawnSafezone                                                 -- from window's top, avoid title bar and safe zone
  maxButtonYSpawnOffset = windowHeight - buttonSpawnSafezone -
  buttonHeight                                                                                                 -- from window's bottom, avoid safe zone and factor in button height
  minButtonXSpawnOffset = (windowWidth - buttonWidth - 2 * buttonSpawnSafezone) *
  (1 - buttonSpawnXRandomness)                                                                                 -- consider the x spawnable space (window width - 2 safe zones (1 left and 1 right) - button width), scale it by the opposite of the randomness
  maxButtonXSpawnOffset = windowWidth - buttonWidth -
  buttonSpawnSafezone                                                                                          -- from window's right edge, avoid safe zone and factor in button width

  -- start animation loop
  animateButton()
end

function terminate()
  disconnect(g_game, {})

  -- clean up animation loop event
  removeEvent(animationEvent)

  -- destroy ui
  jumpWindow:destroy()
end

-- get a random position for the button to spawn completely within the window
function getRandomButtonPosition()
  local buttonPos = jumpButton:getPosition()
  local windowPos = jumpWindow:getPosition()
  buttonPos.x = windowPos.x + math.random(minButtonXSpawnOffset, maxButtonXSpawnOffset)
  buttonPos.y = windowPos.y + math.random(minButtonYSpawnOffset, maxButtonYSpawnOffset)
  return buttonPos
end

-- animation loop to move the button
function animateButton()
  local buttonPos = jumpButton:getPosition()
  local windowPos = jumpWindow:getPosition()

  -- move button towards the negative x direction by some distance every tick/execution
  buttonPos.x = buttonPos.x - distancePerTick

  -- reset the button position randomly if the button reached the edge
  if (buttonPos.x < windowPos.x + buttonSpawnSafezone) then
    buttonPos = getRandomButtonPosition()
  end

  -- actually push the position to the button ui
  jumpButton:setPosition(buttonPos)

  -- get a reference to the event for cleanup on terminate
  animationEvent = scheduleEvent(animateButton, tickTime)
end

-- callback for when jump button is clicked
function jump()
  -- directly set button position randomly
  jumpButton:setPosition(getRandomButtonPosition())
end
