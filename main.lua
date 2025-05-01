local state
local notifSound
local bannerImage
local logoImage
local shineImage
local segoeFont
local segoeBigFont -- Font for larger text
local transitionTimer
local shineX -- Position of the shine effect on the progress bar
local easterEggActive -- Flag for Easter Egg activation

function love.load()
    love.window.setTitle("SuperCool Software Installer")
    love.window.setMode(600, 400)

    -- Initialize variables
    state = "welcome" -- Start directly with the welcome screen
    progress = 0
    isComplete = false
    transitionTimer = 0
    targetState = nil
    transitioning = false
    shineX = -100 -- Start further left off the progress bar
    easterEggActive = false -- Easter Egg initially inactive
    messages = {
        "Welcome to the SuperCool Software Installer",
        "Please wait while we prepare the installation...",
        "Installing components...",
        "Finalizing setup...",
        "Installation complete!"
    }
    fileNames = {
        "wormhole.dll", "quantumflux.dll", "alien_API.exe", "system32.dll", "mainlogic.so",
        "helper.dll", "runtime_api.dll", "security_patch.bin", "install.log", "skynet_protocols.exe"
    }
    currentFile = ""

    -- Load assets
    notifSound = love.audio.newSource("assets/notif.mp3", "static")
    bannerImage = love.graphics.newImage("assets/banner.png")
    logoImage = love.graphics.newImage("assets/logo.png")
    shineImage = love.graphics.newImage("assets/shine.png") -- Load the shine image

    -- Load custom Segoe UI fonts
    segoeFont = love.graphics.newFont("assets/segoeui.ttf", 16) -- Regular size font
    segoeBigFont = love.graphics.newFont("assets/segoeui.ttf", 32) -- Large font for headings
end

function startTransition(nextState)
    transitioning = true -- Begin transition
    targetState = nextState -- Set the target state for transition
    transitionTimer = 0 -- Reset the transition timer
end


function love.update(dt)
    -- Handle transitions
    if transitioning then
        transitionTimer = transitionTimer + dt
        if transitionTimer >= 1 then
            transitioning = false
            transitionTimer = 0
            state = targetState
        end
    end

    -- Update progress during installation
    if state == "installing" and not isComplete and not easterEggActive then
        if messages[math.min(math.floor(progress / 25) + 1, #messages)] == "Welcome to the SuperCool Software Installer" then
            progress = progress + dt * 2 -- Slow progress at the start
        elseif messages[math.min(math.floor(progress / 25) + 1, #messages)] == "Please wait while we prepare the installation..." then
            progress = progress + dt * 10 -- Normal speed after this message
        else
            progress = progress + dt * 10 -- Normal progress
        end

        shineX = shineX + dt * 300 -- Move shine to the right faster
        if shineX > 410 then
            shineX = -100 -- Reset shine further to the left for smooth re-entry
        end

        if progress >= 100 then
            progress = 100
            isComplete = true
            state = "finished" -- Transition to finished state
            notifSound:play()
        else
            currentFile = fileNames[math.random(1, #fileNames)]
            print("Installing: " .. currentFile) -- Log file name in console
        end
    end
end

-- Function to draw the shine effect first
local function drawShineEffect()
    love.graphics.setColor(1, 1, 1, 0.8) -- Semi-transparent effect for the shine
    love.graphics.draw(shineImage, 200 + shineX, 200, 0, 1, 1) -- Moving shine image
end

-- Function to draw the banner and logo on top of everything
local function drawBannerAndLogo()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bannerImage, 0, 0, 0, 1, 400 / bannerImage:getHeight()) -- Banner spans the left side
    love.graphics.draw(logoImage, 160, 10, 0, 1, 1) -- Logo positioned at the top beside the banner
end

-- Function to draw the progress bar
local function drawProgressBar()
    love.graphics.setColor(0, 0, 0) -- Black outline
    love.graphics.rectangle("line", 200, 200, 350, 30)

    love.graphics.setColor(0.1, 0.8, 0.1) -- Green fill for progress
    love.graphics.rectangle("fill", 200, 200, 3.5 * progress, 30)

    -- Draw shine effect behind the banner
    drawShineEffect()
end


function love.draw()
    love.graphics.clear(1, 1, 1) -- Set the background to white

    if easterEggActive then
        -- Easter Egg screen
        love.graphics.setFont(segoeBigFont) -- Use Segoe UI large font
        love.graphics.setColor(1, 0, 0) -- Red text for chaos
        love.graphics.printf("WARNING: SYSTEM OVERRIDE DETECTED", 0, 50, 600, "center")
        love.graphics.setFont(segoeFont)
        love.graphics.printf("Activating Quantum Flux Generator...\nUploading AI Protocols...\nLaunching alien_API.exe...", 0, 150, 600, "left")
        love.graphics.printf("Good luck. Skynet installation complete.", 0, 300, 600, "center")
    else
        -- Normal Installation Screens
        if state == "welcome" then
            love.graphics.setFont(segoeBigFont)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("SuperCool Software Setup Wizard", 200, 100, 400, "left")
            love.graphics.setFont(segoeFont)
            love.graphics.rectangle("line", 300, 300, 100, 40) -- Button outline
            love.graphics.printf("Next", 300, 310, 100, "center")
        elseif state == "menu" then
            love.graphics.setFont(segoeBigFont)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Choose an option:", 200, 100, 400, "left")
            love.graphics.setFont(segoeFont)
            love.graphics.rectangle("line", 200, 250, 150, 40) -- Install Program button
            love.graphics.printf("Install Program", 200, 260, 150, "center")
            love.graphics.rectangle("line", 400, 250, 150, 40) -- Install Update button
            love.graphics.printf("Install Update", 400, 260, 150, "center")
        elseif state == "update" then
            love.graphics.setFont(segoeBigFont)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("No App found, install program instead?", 200, 150, 400, "left")
            love.graphics.setFont(segoeFont)
            love.graphics.rectangle("line", 300, 300, 100, 40) -- OK button outline
            love.graphics.printf("OK", 300, 310, 100, "center")
        elseif state == "installing" then
            love.graphics.setFont(segoeFont)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(messages[math.min(math.floor(progress / 25) + 1, #messages)], 200, 60, 350, "left")
            love.graphics.printf("Installing: " .. currentFile, 200, 160, 350, "left")
            drawProgressBar()
        elseif state == "finished" then
            -- Finished screen content (no Exit button)
            love.graphics.setFont(segoeBigFont)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Installation complete!", 200, 150, 400, "left")
        end
    end

    drawBannerAndLogo() -- Always draw the banner and logo on top
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Check for left mouse button
        if state == "welcome" and not transitioning then
            -- Check if "Next" button is clicked
            if x >= 300 and x <= 400 and y >= 300 and y <= 340 then
                startTransition("menu") -- Transition to menu state
            end
        elseif state == "menu" and not transitioning then
            -- Check if "Install Program" button is clicked
            if x >= 200 and x <= 350 and y >= 250 and y <= 290 then
                startTransition("installing") -- Transition to installing state
            -- Check if "Install Update" button is clicked
            elseif x >= 400 and x <= 550 and y >= 250 and y <= 290 then
                startTransition("update") -- Transition to update state
            end
        elseif state == "update" and not transitioning then
            -- Check if "OK" button is clicked
            if x >= 300 and x <= 400 and y >= 300 and y <= 340 then
                -- Start the installer when "OK" is clicked
                progress = 0 -- Reset progress bar
                isComplete = false -- Reset completion status
                currentFile = "" -- Reset displayed file name
                startTransition("installing") -- Transition to installing state
            end
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- Check for the specific key combination: Ctrl + Alt + Shift + E
    if key == "e" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lalt") and love.keyboard.isDown("lshift") then
        easterEggActive = true -- Activate the Easter Egg
        state = nil -- Clear other state for the chaotic Easter Egg
        print("Easter Egg Activated!") -- Log to console for debugging
    end
end