local clickTable = {}
local formatted = "" -- For writing all the click info to the screen
local timeElapsed = 0
local testDuration = 2
local clickCooldown = 1 -- Don't start this amount of seconds after test finish
local canRunTest = true
local testEnd = nil -- Time of last finished test
local testStart = nil -- Time of test start
local text = "Click to start"
local bestCps = 0

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.window.setMode(1000, 1000, {resizable = true, vsync = false})
	love.window.setTitle("Click Speed Analyser")
end


function love.update(dt)
	if love.keyboard.isDown('escape') then love.event.quit() end
	local now = love.timer.getTime()

	-- Stop test, enable cooldown
	if testStart and (now >= testStart + testDuration) then 
		testStart = nil
		timeElapsed = 0
		canRunTest = false
		testEnd = now
		if clickTable[#clickTable]['up'] == nil then
			clickTable[#clickTable]['up'] = testDuration
		end
	end
	
	-- Check if cooldown should end
	if not canRunTest then
		local remaining = testEnd + clickCooldown - now
		text = "Wait: " .. tostring(remaining)
		if remaining <= 0 then
			canRunTest = true
			text = "Click to start"
		end
	end

	-- Update timeElapsed
	if testStart then
		timeElapsed = (now - testStart) / testDuration
		text = "Click super fast! " .. tostring(testDuration - timeElapsed * testDuration)
	end
end


function love.mousepressed(x,y,button)
	local down = love.timer.getTime()
	if canRunTest then
		if testStart==nil then
			testStart = down 
			clickTable = {}
			formatted = ""
		end
		
		
			-- Start a new click entry
			table.insert(clickTable, {
				down			= down - testStart,
				up				= nil,
				spacing		= 0
			})
		
	end
end


function love.mousereleased(x,y,button)
	if testStart then
		local up = love.timer.getTime()
	
		if #clickTable>1 then
			-- Get spacing/delay/gap between current and previous click
			clickTable[#clickTable]['spacing'] = clickTable[#clickTable].down - clickTable[#clickTable-1].up
		end
		clickTable[#clickTable]['up'] = up - testStart
		local duration = (clickTable[#clickTable].up - clickTable[#clickTable].down)*1000
		local spacing = clickTable[#clickTable]['spacing']*1000
		formatted = formatted .. string.format("%02d\t Duration %8.2f\t Front spacing %8.2f \n", #clickTable, tostring(duration), tostring(spacing))
	
		-- for k,v in ipairs(clickTable) do
		-- 	print(k, v.down, v.up, v.spacing)
		-- end
		-- print()
	end
end

function love.draw()
	local width, height = love.graphics.getDimensions()
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(text, 0, 10, width/2, 'center', 0, 2, 2)

	local cps = #clickTable/testDuration
	if cps > bestCps then bestCps = cps end
	love.graphics.printf("CPS: "..cps..", Best: "..bestCps, 0, 40, width/1.5, 'center', 0, 1.5, 1.5)

	love.graphics.printf(tostring(love.timer.getFPS()), 0, 10, width/1.5, 'right', 0, 1.5, 1.5)
	
	love.graphics.printf(formatted, 10, 110, width)
	
	love.graphics.setColor(1,1,1,0.2)
	for k,v in ipairs(clickTable) do
		local x = width*(v.down/testDuration)
		local w = 0
		if v.up then
			w = width*(v.up/testDuration)-x
		else
			w = width*timeElapsed-x
		end
		love.graphics.rectangle('fill', x, 80, w, 20)
	end
end
