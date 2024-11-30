local UI = game:GetObjects('rbxassetid://119242040448475')[1]
local UIObjects, NotifCenter = UI.Objects, UI.Frame
local Icons = UIObjects.Icons:GetAttributes()
local IconColors = UIObjects.Icons.Colors:GetAttributes()
local RectOffsets = UIObjects.Icons.Offsets:GetAttributes()
getgenv().IvNotify = function(Title, Message, Type, Duration)
	if not Type or not Icons[Type] then warn(`Missing notification type. Received: {Type}`) return end
	Duration = tonumber(Duration) or 5
	
	local Notification,s = UIObjects.Notification:Clone()
	Notification.Body.TopBar.Icon.ImageRectOffset = RectOffsets[Type]
	Notification.Body.TopBar.Icon.ImageColor3 = IconColors[Type]
	Notification.Body.TopBar.Icon.Image = Icons[Type]
	Notification.Body.TopBar.Title.Text = Title
	Notification.Body.Message.Text = Message
	
	s=Notification.Body.TopBar.Close.MouseButton1Click:Connect(function()
		Notification.Body:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.6) task.wait(0.2)
		if s then
			Notification:Destroy() s=nil
		end
	end)
	
	Notification.Parent = NotifCenter
	Notification.Body:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5, false, function()
		task.delay(Duration, function()
			Notification.Body:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.8) task.wait(0.4)
			if s then
				Notification:Destroy() s=nil
			end	
		end)
	end)
end

--> Usage
--> IvNotify(Title: string, Message: string, Type: string, Duration: number?)
