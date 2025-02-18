local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local displayChatMessageEvent = ReplicatedStorage:WaitForChild("DisplayChatMessage")

displayChatMessageEvent.OnClientEvent:Connect(function(message)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[AI]: "..message,
        Color = Color3.new(0.00392157, 1, 0.701961),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
    })
end)
