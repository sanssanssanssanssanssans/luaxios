local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local displayChatMessageEvent = ReplicatedStorage:FindFirstChild("DisplayChatMessage")
local Axios = require(game.ServerScriptService.luaxios)
if not displayChatMessageEvent then
    displayChatMessageEvent = Instance.new("RemoteEvent")
    displayChatMessageEvent.Name = "DisplayChatMessage"
    displayChatMessageEvent.Parent = ReplicatedStorage
end

local axios = Axios.new({
    baseURL = "",
    headers = {},
    timeout = 10,
    retryCount = 3,
    retryDelay = 1,
})

local safetySettings = {
    { category = "HARM_CATEGORY_HARASSMENT", threshold = "BLOCK_NONE" },
    { category = "HARM_CATEGORY_HATE_SPEECH", threshold = "BLOCK_NONE" },
    { category = "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold = "BLOCK_NONE" },
    { category = "HARM_CATEGORY_DANGEROUS_CONTENT", threshold = "BLOCK_NONE" }
}

local userMemory = {}

local function generateAIResponse(prompt, userId, callback)
    local googleApiKey = "GOOGLE_API"
    local previousMemory = userMemory[userId] or {}
    local context = table.concat(previousMemory, "\n")
    local combinedPrompt = "What's your name?\nI'm Matrix\nWhat's my name?\nYour name is " .. userId .. "\n" .. context .. prompt

    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    local data = {
        contents = {{
            parts = {{
                text = combinedPrompt
            }}
        }},
        safetySettings = safetySettings,
        generationConfig = {
            temperature = 1
        }
    }

    local headers = {
        ["Content-Type"] = "application/json",
        ["x-goog-api-key"] = googleApiKey
    }

    axios:post(url, data, { headers = headers }, function(response)
        if response.status ~= 200 then
            callback("No response generated.")
            return
        end

        local responseText = response.data.candidates[1].content.parts[1].text or "No response generated."
        table.insert(previousMemory, prompt)
        table.insert(previousMemory, responseText)
        userMemory[userId] = previousMemory
        callback(responseText)
    end)
end


game:GetService("Players").PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if message:sub(1, 4):lower() == "/ai " then
            local prompt = message:sub(5)
            generateAIResponse(prompt, player.UserId, function(response)
                displayChatMessageEvent:FireClient(player, response)
            end)
        end
    end)
end)


--Local Script
--[[
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
]]
