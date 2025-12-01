local SFX = require(script.SoundPlayer)

local Dialogue = {}

local Assets = script:WaitForChild("UiAssets")

local Sprites = {
	Sir_pwnsalot = Assets.Sprites.Sir_pwnsalot.Sir_pwnsalot,
	Conquista = Assets.Sprites.Conquista.Conquista
}

local function TWEffect(TextLabel, Message, Length) -- typewriter effect
	local MsgNumber = #Message -- counts letters
	TextLabel.Text = Message -- sets full text
	TextLabel.MaxVisibleGraphemes = 0 -- hides text
	TextLabel.Visible = true -- shows label
	for i = 1, MsgNumber do
		TextLabel.MaxVisibleGraphemes = i -- reveals letters one by one
		task.wait(Length) -- waits between each letter
	end
	TextLabel.MaxVisibleGraphemes = -1 -- shows full text
end

local function ReverseTWEffect(TextLabel, Length) -- reverse typewriter effect
	if TextLabel.MaxVisibleGraphemes ~= 0 then -- checks if text is visible
		local Message = TextLabel.Text
		local MsgNumber = #Message
		TextLabel.MaxVisibleGraphemes = -1 -- starts fully visible
		TextLabel.Visible = true
		for i = 1, MsgNumber do
			TextLabel.MaxVisibleGraphemes = MsgNumber - i -- hides letters
			task.wait(Length)
		end
		TextLabel.MaxVisibleGraphemes = 0 -- hides all
	end
end

function Dialogue:ReturnSprites() -- return sprites function
	return Sprites
end

function Dialogue:CreateDialogue(Player)
	local ScreenGui = Instance.new("ScreenGui") -- creates main gui
	ScreenGui.Name = "Dialogue"
	
	local Overlay = Assets.Overlay:Clone() -- creates overlay ui
	Overlay.Parent = ScreenGui
	
	local SetUpDialogue = {}
	
	function SetUpDialogue:ShowUi()
		self.Visible = true -- marks dialogue as active
		SFX:PlaySound("DialogueEnter", workspace) -- plays open sound
		Overlay.Position = UDim2.new(0.5, 0, 1, 0) -- starts offscreen
		Overlay.ImageTransparency = 1 -- hidden
		ScreenGui.Parent = Player.PlayerGui -- parents gui to playergui
		game.TweenService:Create(Overlay, TweenInfo.new(.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0.55, 0), ImageTransparency = 0}):Play() -- animates ui in
	end
	
	function SetUpDialogue:RemoveUi()
		self.Visible = false -- hides dialogue 
		game.Debris:AddItem(ScreenGui, 1.4) -- adds gui to the debris which will delete it 1.4 seconds later
		local SpriteD = false
		for i,v in pairs(ScreenGui:GetChildren()) do -- loops through gui to get all the sprites
			if v:GetAttribute("Sprite") == false then
				SpriteD = true
				task.spawn(function()
					game.TweenService:Create(v, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(111, 111, 111), Size = UDim2.new(0.32, 0, 0.7, 0)}):Play() -- animates sprite
					wait(.2)
					game.TweenService:Create(v, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = v.Position + UDim2.new(0, 0, 2, 0)}):Play() -- animates sprite
				end)
			end
		end
		if SpriteD then
			game.TweenService:Create(Overlay, TweenInfo.new(.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, .35), {Position = Overlay.Position + UDim2.new(0, 0, 1.25, 0), Transparency = 1}):Play() -- hides overlay with delay
		else
			game.TweenService:Create(Overlay, TweenInfo.new(.6, Enum.EasingStyle.Quad), {Position = Overlay.Position + UDim2.new(0, 0, 1.25, 0), Transparency = 1}):Play() -- hides overlay
		end
	end
	
	function SetUpDialogue.DialogueBoxClicked(Function)
		local Clicked
		Clicked = Overlay.ContinueButton.MouseButton1Click:Connect(function() -- waits for button click
			Clicked:Disconnect() -- disconnect clicked function
			Function() -- calls next step
		end)
	end
	
	function SetUpDialogue:WaitTillClicked()
		local Clicked
		local Waiting = false
		Clicked = Overlay.ContinueButton.MouseButton1Click:Connect(function() -- waits for click
			Clicked:Disconnect()
			Waiting = true -- continues when clicked
		end)
		while Waiting == false do -- loop until clicked
			task.wait()
		end
	end
	
	local function CreateButtonFrame()
		local ButtonFrame = ScreenGui:FindFirstChild("ButtonFrame")
		if not ScreenGui:FindFirstChild("ButtonFrame") then -- creates frame if missing
			local BF = Assets.ButtonFrame:Clone()
			BF.Position += UDim2.new(0, 0, .2, 0) -- start offset
			BF.Parent = ScreenGui
			game.TweenService:Create(BF, TweenInfo.new(.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.507, 0, 0.397, 0)}):Play() -- animates in
			ButtonFrame = BF
		end
		return ButtonFrame
	end
	
	function SetUpDialogue:CreateButton(Msg)
		self.CanClick = true -- enables buttons
		
		local Frame = CreateButtonFrame()
		local Button = Assets.Button:Clone() -- creates button
		Button.Response.Text = "" -- clears text
		Button.Size = UDim2.new(2, 0, 1.552, 0) -- start size
		Button.Parent = Frame
		task.delay(.05, function()
			game.TweenService:Create(Button, TweenInfo.new(.3, Enum.EasingStyle.Back), {Size = UDim2.new(3.48, 0, 1.552, 0)}):Play() -- animates button
			TWEffect(Button.Response, Msg, 0.01) -- displays the text
		end)
		
		local ButtonFunctions = {}
		
		function ButtonFunctions.ButtonClicked(FunctionListed)
			local PSize = UDim2.new(3.48, 0, 1.552, 0) -- normal size
			local NSize = UDim2.new(3.48, 0, 1.552, 0) + UDim2.new(.3, 0, .3, 0) -- hover size
			Button.MouseEnter:Connect(function()
				game.TweenService:Create(Button, TweenInfo.new(.35, Enum.EasingStyle.Back), {Size = NSize}):Play() -- animate on hover
			end)
			Button.MouseLeave:Connect(function()
				game.TweenService:Create(Button, TweenInfo.new(.35, Enum.EasingStyle.Back), {Size = PSize}):Play() -- animate on exit
			end)
			
			Button.MouseButton1Click:Connect(function()
				if self.CanClick then -- check if allowed
					if self.CanClick == true then
						FunctionListed() -- runs given function
					end
				end
			end)
		end
		
		return ButtonFunctions -- returns button actions
	end
	
	function SetUpDialogue:RemoveButtons()
		self.CanClick = false -- disables clicks
		local Frame = CreateButtonFrame()
		game.Debris:AddItem(Frame, .3) -- removes frame later
		for i,v in pairs(Frame:GetChildren()) do
			if v:IsA("ImageButton") then -- animates button shrink
				game.TweenService:Create(v, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(2, 0, 1.552, 0)}):Play()
			end
		end
		game.TweenService:Create(Frame, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = Frame.Position + UDim2.new(0, 0, 0.45, 0)}):Play() -- moves frame down
	end
	
	function SetUpDialogue:SetDialogueMessage(Message)
		local Msg = Overlay.SpriteMsg -- text label
		TWEffect(Msg, Message, 0.01) -- writes message
	end
	
	function SetUpDialogue:ResetSprites(Sprite1, Sprite2)
		-- ⌄⌄ Y vector variables that will change depending on if a sprite is a player ⌄⌄
		local Y1 = 0.6
		local Y2 = 0.6
		if game.Players:FindFirstChild(Sprite1.Name) then
			Y1 = 0.7
		elseif game.Players:FindFirstChild(Sprite2.Name) then
			Y2 = 0.7
		end
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		ReverseTWEffect(Overlay.SpriteName, 0.01) -- hides speaker name
		
		local Pos1 = Sprite1.Position
		game.TweenService:Create(Sprite1, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.428, 0, 0.825, 0), Position = UDim2.new(Pos1.X.Scale, 0, Y1, 0)}):Play() -- resets sprite
		local Pos2 = Sprite2.Position
		game.TweenService:Create(Sprite2, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.428, 0, 0.825, 0), Position = UDim2.new(Pos2.X.Scale, 0, Y2, 0)}):Play() -- resets sprite
	end
	
	function SetUpDialogue:NoSpeakers(Sprite1, Sprite2)
		-- ⌄⌄ Y vector variables that will change depending on if a sprite is a player ⌄⌄
		local Y1 = 0.65
		local Y2 = 0.65
		if game.Players:FindFirstChild(Sprite1.Name) then
			Y1 = 0.75 -- adjusts for player sprite
		elseif game.Players:FindFirstChild(Sprite2.Name) then
			Y2 = 0.75
		end
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		ReverseTWEffect(Overlay.SpriteName, 0.01) -- hides speaker name
		
		local Pos1 = Sprite1.Position
		game.TweenService:Create(Sprite1, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(156, 156, 156), Size = UDim2.new(0.42, 0, 0.8, 0), Position = UDim2.new(Pos1.X.Scale, 0, Y1, 0)}):Play() -- lowers the sprite
		local Pos2 = Sprite2.Position
		game.TweenService:Create(Sprite2, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(156, 156, 156), Size = UDim2.new(0.42, 0, 0.8, 0), Position = UDim2.new(Pos2.X.Scale, 0, Y2, 0)}):Play() -- lowers the sprite
	end
	
	function SetUpDialogue:SetSpeakers(Speaking, NotSpeaking)
		-- ⌄⌄ Y vector variables that will change depending on who is speaking ⌄⌄
		local Y1 = 0.6
		local Y2 = 0.65
		if game.Players:FindFirstChild(Speaking.Name) then
			Y1 = 0.7
		elseif game.Players:FindFirstChild(NotSpeaking.Name) then
			Y2 = 0.75
		end
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		local SpeakingPos = Speaking.Position
		game.TweenService:Create(Speaking, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.45, 0, 0.85, 0), Position = UDim2.new(SpeakingPos.X.Scale, 0, Y1, 0)}):Play() -- brings up the speaking sprite
		local NotSpeakingPos = NotSpeaking.Position
		game.TweenService:Create(NotSpeaking, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(156, 156, 156), Size = UDim2.new(0.42, 0, 0.8, 0), Position = UDim2.new(NotSpeakingPos.X.Scale, 0, Y2, 0)}):Play() -- lowers non speaking sprite
		
		task.spawn(function()
			TWEffect(Overlay.SpriteName, Speaking.Name, 0.01) -- shows speaker name
		end)
	end
	
	function SetUpDialogue:CreateSprite(CS, L)
		if self.Visible then -- ensures ui is shown
			if self.Visible == false then
				SetUpDialogue:ShowUi()
			end
		else
			SetUpDialogue:ShowUi()
		end
		local Sprite
		local Y = 0.6
		if Sprites[CS.Name] ~= nil then -- checks for preset sprite
			Sprite = CS:Clone()
		else
			Sprite = Assets.Sprites.PlayerSprite:Clone() -- fallback player sprite
			Sprite.Name = CS.Name
			Sprite.Image = game.Players:GetUserThumbnailAsync(CS.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420) -- loads avatar
			Y = 0.7
		end
		
		task.delay(.35, function()
			local X = 0.835
			if L then -- flips sprite if on left side
				X = 0.145
				Sprite.ImageRectOffset = Vector2.new(999, 0)
				Sprite.ImageRectSize = Vector2.new(-999, 999)
			end

			Sprite.Position = UDim2.new(X, 0, 1.42, 0) -- starts offscreen
			Sprite.Parent = ScreenGui

			game.TweenService:Create(Sprite, TweenInfo.new(.4, Enum.EasingStyle.Back), {Position = UDim2.new(X, 0, Y, 0)}):Play() -- animates sprite in
		end)
		
		local SpriteFunctions = {}
		
		function SpriteFunctions:RemoveSprite()
			task.spawn(function()
				game.Debris:AddItem(Sprite, .65) -- removes sprite later
				game.TweenService:Create(Sprite, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(111, 111, 111), Size = UDim2.new(0.32, 0, 0.7, 0)}):Play() -- make the sprite smaller
				wait(.2)
				game.TweenService:Create(Sprite, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = Sprite.Position + UDim2.new(0, 0, 2, 0)}):Play() -- moves the sprite down
			end)
		end
		
		function SpriteFunctions:ReturnSprite()
			return Sprite -- returns sprite instance
		end
		
		function SpriteFunctions:ReturnExpressions()
			local Expressions = {} -- expression table
			
			for i,v in pairs(CS.Parent.Expressions:GetChildren()) do
				Expressions[v.Name] = v -- 
			end
			
			return Expressions -- return the table
		end
		
		function SpriteFunctions:ChangeExpression(E)
			Sprite.Image = E.Image -- sets sprite image to given image
			game.TweenService:Create(Sprite, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {Size = Sprite.Size + UDim2.new(.1, 0, .1, 0)}):Play() -- animate the expression in
		end
		
		return SpriteFunctions
	end
	
	return SetUpDialogue
end

return Dialogue
