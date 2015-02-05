-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )


--------------------------------------------

-- Forward declarations and other locals
local _W, _H = display.contentWidth, display.contentHeight --Width and Height variables to place objects
local background --Acts as the button that moves paddle
local isPaused = true --Check if game started
local randNum = math.random

--Main menu buttons
local playBtn -- Play button
local leaderboardsBtn --Opens up gamecenter
local settingsBtn --Shows settings options

--Setting menu buttons
local rateAppBtn
local muteMusicBtn
local muteSFXBtn

--In game display objects
local pauseBtn
local score = 0 --Saves the score
local scoreText --Text that displays the score
local highScore --High score pulled from file
local highScoreText --Text that displays high score
local multiplier = 1 --Multiplier for score
local multiplierCount = 0 --Counts up to 10 then adds to multiplier
local multiplierText --Text that displays multiplier

--Game objects
local ball
local paddle
local topWall --Walls for ball to bounce from
local leftWall
local rightWall

--Display groups to hold different objects
local menuGroup = display.newGroup()
local settingsGroup = display.newGroup()


-- Functions for button presses
local function onPlayBtnRelease(event)
	if event.phase == 'ended' then
		isPaused = false
		--ball:applyLinearImpulse( 0, 10, ball.x, ball.y )
		local function startGame( )
			ball:setLinearVelocity( 0, 200 )
		end
		transition.to(menuGroup, {time = 500, y = menuGroup.y+300, onComplete = startGame})
	end
end

local function movePaddle( event )
	if isPaused == false then
		paddle.x = event.x
	end
end

local function bounceBall( event )
	if ball.x < paddle.x then
		ball:setLinearVelocity( randNum( -500,-200 ), randNum( -600, -200 ) )
	elseif ball.x > paddle.x then
		ball:setLinearVelocity( randNum( 200, 500 ), randNum( -600, -200 ) )
	else
		ball:setLinearVelocity( randNum( -500, 400 ), randNum( -600, -200 ) )
	end
end

local function addPoints( event )
	if event.phase == 'ended' then
		score = score + 1 * multiplier
		multiplierCount = multiplierCount+1
		print( score )
		scoreText.text = score
		if multiplierCount == 10 then
			multiplierCount = 0
			multiplier = multiplier + 1
		end
	end
end

local function gameOver( event )
	if ball.y > _H+20 then
		physics.pause()
	end
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	background = display.newRect(0, 0, _W, _H )
	background:setFillColor(46/255, 204/255, 113/255)
	background.x = _W/2
	background.y = _H/2

	topWall = display.newRect( 0, 0, _W, 5 )
	topWall.x = _W/2
	topWall:setFillColor( 34/255 )
	physics.addBody( topWall, "static", {density=5, friction=0, bounce=1 } )

	leftWall = display.newRect( 0, 0, 5, _H )
	leftWall.y = _H/2
	leftWall:setFillColor( 1/255 )
	physics.addBody( leftWall, "static", {density=5, friction=0, bounce=1 } )

	rightWall = display.newRect( 0, 0, 5, _H )
	rightWall.y = _H/2
	rightWall.x = _W
	rightWall:setFillColor( 1/255 )
	physics.addBody( rightWall, "static", {density=5, friction=0, bounce=.5 } )

	paddle = display.newRect( 0, 0, 70, 10 )
	paddle.x = _W/2
	paddle.y = _H/2 + 100
	paddle:setFillColor( 34/255 )
	physics.addBody( paddle, "static", {density=5, friction=0, bounce=.5 } )
	paddle.isFixedRotation = true

	ball = display.newRect( 0, 0, 12, 12 )
	ball.x = _W/2
	ball.y = _H/2-100
	ball:setFillColor( 34/255 )
	physics.addBody( ball, "dynamic", {density=1, friction=0, bounce=.7 } )
	ball.isFixedRotation = true

	scoreText = display.newText( score, 0, 0, native.systemFont, 32 )
	scoreText.x = _W/2
	scoreText.y = 50

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/playBtn.png",
		overFile="images/playBtnOver.png",
		width=115, height=83,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = _W * 0.5
	playBtn.y = _H - 125
	menuGroup:insert( playBtn )

	leaderboardsBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/leaderboardsBtn.png",
		overFile="images/leaderboardsBtnOver.png",
		width=80, height=82,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	leaderboardsBtn.x = playBtn.x - 110
	leaderboardsBtn.y = _H - 125
	menuGroup:insert( leaderboardsBtn )

	settingsBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/settingsBtn.png",
		overFile="images/settingsBtnOver.png",
		width=80, height=82,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	settingsBtn.x = playBtn.x + 110
	settingsBtn.y = _H - 125
	menuGroup:insert( settingsBtn )

	-- all display objects must be inserted into group
	--sceneGroup:insert( playBtn )
	sceneGroup:insert(background)
	sceneGroup:insert( menuGroup )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		background:addEventListener("touch", movePaddle)
		paddle:addEventListener( "collision", bounceBall )
		topWall:addEventListener( "collision", addPoints )
		Runtime:addEventListener( "enterFrame", gameOver )
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene