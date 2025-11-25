local SFX = require(script.SoundPlayer)

local Dialogue = {}

local Assets = script:WaitForChild("UiAssets")

local Sprites = {
	Sir_pwnsalot = Assets.Sprites.Sir_pwnsalot.Sir_pwnsalot,
	Conquista = Assets.Sprites.Conquista.Conquista
}

local function TWEffect(TextLabel, Message, Length)
	local MsgNumber = #Message
	TextLabel.Text = Message
	TextLabel.MaxVisibleGraphemes = 0
	TextLabel.Visible = true
	for i = 1, MsgNumber do
		TextLabel.MaxVisibleGraphemes = i
		task.wait(Length)
	end
	TextLabel.MaxVisibleGraphemes = -1
end

local function ReverseTWEffect(TextLabel, Length)
	if TextLabel.MaxVisibleGraphemes ~= 0 then
		local Message = TextLabel.Text
		local MsgNumber = #Message
		TextLabel.MaxVisibleGraphemes = -1
		TextLabel.Visible = true
		for i = 1, MsgNumber do
			TextLabel.MaxVisibleGraphemes = MsgNumber - i
			task.wait(Length)
		end
		TextLabel.MaxVisibleGraphemes = 0
	end
end

function Dialogue:ReturnSprites()
	return Sprites
end

function Dialogue:CreateDialogue(Player)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Dialogue"
	
	local Overlay = Assets.Overlay:Clone()
	Overlay.Parent = ScreenGui
	
	local SetUpDialogue = {}
	
	function SetUpDialogue:ShowUi()
		self.Visible = true
		SFX:PlaySound("DialogueEnter", workspace)
		Overlay.Position = UDim2.new(0.5, 0, 1, 0)
		Overlay.ImageTransparency = 1
		ScreenGui.Parent = Player.PlayerGui
		game.TweenService:Create(Overlay, TweenInfo.new(.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0.55, 0), ImageTransparency = 0}):Play()
	end
	
	function SetUpDialogue:RemoveUi()
		self.Visible = false
		game.Debris:AddItem(ScreenGui, 1.4)
		local SpriteD = false
		for i,v in pairs(ScreenGui:GetChildren()) do
			if v:GetAttribute("Sprite") == false then
				SpriteD = true
				spawn(function()
					game.TweenService:Create(v, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(111, 111, 111), Size = UDim2.new(0.32, 0, 0.7, 0)}):Play()
					wait(.2)
					game.TweenService:Create(v, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = v.Position + UDim2.new(0, 0, 2, 0)}):Play()
				end)
			end
		end
		if SpriteD then
			game.TweenService:Create(Overlay, TweenInfo.new(.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, .35), {Position = Overlay.Position + UDim2.new(0, 0, 1.25, 0), Transparency = 1}):Play()
		else
			game.TweenService:Create(Overlay, TweenInfo.new(.6, Enum.EasingStyle.Quad), {Position = Overlay.Position + UDim2.new(0, 0, 1.25, 0), Transparency = 1}):Play()
		end
	end
	
	function SetUpDialogue.DialogueBoxClicked(Function)
		local Clicked
		Clicked = Overlay.ContinueButton.MouseButton1Click:Connect(function()
			Clicked:Disconnect()
			Function()
		end)
	end
	
	function SetUpDialogue:WaitTillClicked()
		local Clicked
		local Waiting = false
		Clicked = Overlay.ContinueButton.MouseButton1Click:Connect(function()
			Clicked:Disconnect()
			Waiting = true
		end)
		while Waiting == false do
			task.wait()
		end
	end
	
	local function CreateButtonFrame()
		local ButtonFrame = ScreenGui:FindFirstChild("ButtonFrame")
		if not ScreenGui:FindFirstChild("ButtonFrame") then
			local BF = Assets.ButtonFrame:Clone()
			BF.Position += UDim2.new(0, 0, .2, 0)
			BF.Parent = ScreenGui
			game.TweenService:Create(BF, TweenInfo.new(.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.507, 0, 0.397, 0)}):Play()
			ButtonFrame = BF
		end
		return ButtonFrame
	end
	
	function SetUpDialogue:CreateButton(Msg)
		self.CanClick = true
		
		local Frame = CreateButtonFrame()
		local Button = Assets.Button:Clone()
		Button.Response.Text = ""
		Button.Size = UDim2.new(2, 0, 1.552, 0)
		Button.Parent = Frame
		delay(.05, function()
			game.TweenService:Create(Button, TweenInfo.new(.3, Enum.EasingStyle.Back), {Size = UDim2.new(3.48, 0, 1.552, 0)}):Play()
			TWEffect(Button.Response, Msg, 0.01)
		end)
		
		local ButtonFunctions = {}
		
		function ButtonFunctions.ButtonClicked(FunctionListed)
			local PSize = UDim2.new(3.48, 0, 1.552, 0)
			local NSize = UDim2.new(3.48, 0, 1.552, 0) + UDim2.new(.3, 0, .3, 0)
			Button.MouseEnter:Connect(function()
				game.TweenService:Create(Button, TweenInfo.new(.35, Enum.EasingStyle.Back), {Size = NSize}):Play()
			end)
			Button.MouseLeave:Connect(function()
				game.TweenService:Create(Button, TweenInfo.new(.35, Enum.EasingStyle.Back), {Size = PSize}):Play()
			end)
			
			Button.MouseButton1Click:Connect(function()
				if self.CanClick then
					if self.CanClick == true then
						FunctionListed()
					end
				end
			end)
		end
		
		return ButtonFunctions
	end
	
	function SetUpDialogue:RemoveButtons()
		self.CanClick = false
		local Frame = CreateButtonFrame()
		game.Debris:AddItem(Frame, .3)
		for i,v in pairs(Frame:GetChildren()) do
			if v:IsA("ImageButton") then
				game.TweenService:Create(v, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(2, 0, 1.552, 0)}):Play()
			end
		end
		game.TweenService:Create(Frame, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = Frame.Position + UDim2.new(0, 0, 0.45, 0)}):Play()
	end
	
	function SetUpDialogue:SetDialogueMessage(Message)
		local Msg = Overlay.SpriteMsg

		TWEffect(Msg, Message, 0.01)
	end
	
	function SetUpDialogue:ResetSprites(Sprite1, Sprite2)
		local Y1 = 0.6
		local Y2 = 0.6
		if game.Players:FindFirstChild(Sprite1.Name) then
			Y1 = 0.7
		elseif game.Players:FindFirstChild(Sprite2.Name) then
			Y2 = 0.7
		end
		
		ReverseTWEffect(Overlay.SpriteName, 0.01)
		
		local Pos1 = Sprite1.Position
		game.TweenService:Create(Sprite1, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.428, 0, 0.825, 0), Position = UDim2.new(Pos1.X.Scale, 0, Y1, 0)}):Play()
		local Pos2 = Sprite2.Position
		game.TweenService:Create(Sprite2, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.428, 0, 0.825, 0), Position = UDim2.new(Pos2.X.Scale, 0, Y2, 0)}):Play()
	end
	
	function SetUpDialogue:NoSpeakers(Sprite1, Sprite2)
		local Y1 = 0.65
		local Y2 = 0.65
		if game.Players:FindFirstChild(Sprite1.Name) then
			Y1 = 0.75
		elseif game.Players:FindFirstChild(Sprite2.Name) then
			Y2 = 0.75
		end
		
		ReverseTWEffect(Overlay.SpriteName, 0.01)
		
		local Pos1 = Sprite1.Position
		game.TweenService:Create(Sprite1, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(156, 156, 156), Size = UDim2.new(0.42, 0, 0.8, 0), Position = UDim2.new(Pos1.X.Scale, 0, Y1, 0)}):Play()
		local Pos2 = Sprite2.Position
		game.TweenService:Create(Sprite2, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(156, 156, 156), Size = UDim2.new(0.42, 0, 0.8, 0), Position = UDim2.new(Pos2.X.Scale, 0, Y2, 0)}):Play()
	end
	
	function SetUpDialogue:SetSpeakers(Speaking, NotSpeaking)
		local Y1 = 0.6
		local Y2 = 0.65
		if game.Players:FindFirstChild(Speaking.Name) then
			Y1 = 0.7
		elseif game.Players:FindFirstChild(NotSpeaking.Name) then
			Y2 = 0.75
		end
		
		local SpeakingPos = Speaking.Position
		game.TweenService:Create(Speaking, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.45, 0, 0.85, 0), Position = UDim2.new(SpeakingPos.X.Scale, 0, Y1, 0)}):Play()
		local NotSpeakingPos = NotSpeaking.Position
		game.TweenService:Create(NotSpeaking, TweenInfo.new(.2, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(156, 156, 156), Size = UDim2.new(0.42, 0, 0.8, 0), Position = UDim2.new(NotSpeakingPos.X.Scale, 0, Y2, 0)}):Play()
		
		spawn(function()
			TWEffect(Overlay.SpriteName, Speaking.Name, 0.01)
		end)
	end
	
	function SetUpDialogue:CreateSprite(CS, L)
		if self.Visible then
			if self.Visible == false then
				SetUpDialogue:ShowUi()
			end
		else
			SetUpDialogue:ShowUi()
		end
		local Sprite
		local Y = 0.6
		if Sprites[CS.Name] ~= nil then
			Sprite = CS:Clone()
		else
			Sprite = Assets.Sprites.PlayerSprite:Clone()
			Sprite.Name = CS.Name
			Sprite.Image = game.Players:GetUserThumbnailAsync(CS.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
			Y = 0.7
		end
		
		delay(.35, function()
			local X = 0.835
			if L then
				X = 0.145
				Sprite.ImageRectOffset = Vector2.new(999, 0)
				Sprite.ImageRectSize = Vector2.new(-999, 999)
			end

			Sprite.Position = UDim2.new(X, 0, 1.42, 0)
			Sprite.Parent = ScreenGui

			game.TweenService:Create(Sprite, TweenInfo.new(.4, Enum.EasingStyle.Back), {Position = UDim2.new(X, 0, Y, 0)}):Play()
		end)
		
		local SpriteFunctions = {}
		
		function SpriteFunctions:RemoveSprite()
			spawn(function()
				game.Debris:AddItem(Sprite, .65)
				game.TweenService:Create(Sprite, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(111, 111, 111), Size = UDim2.new(0.32, 0, 0.7, 0)}):Play()
				wait(.2)
				game.TweenService:Create(Sprite, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = Sprite.Position + UDim2.new(0, 0, 2, 0)}):Play()
			end)
		end
		
		function SpriteFunctions:ReturnSprite()
			return Sprite
		end
		
		function SpriteFunctions:ReturnExpressions()
			local Expressions = {}
			
			for i,v in pairs(CS.Parent.Expressions:GetChildren()) do
				Expressions[v.Name] = v
			end
			
			return Expressions
		end
		
		function SpriteFunctions:ChangeExpression(E)
			Sprite.Image = E.Image
			game.TweenService:Create(Sprite, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {Size = Sprite.Size + UDim2.new(.1, 0, .1, 0)}):Play()
		end
		
		return SpriteFunctions
	end
	
	return SetUpDialogue
end

return Dialogue
