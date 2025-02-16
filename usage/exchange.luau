local HttpService = game:GetService("HttpService")
local Axios = require("./luaxios")
local axios = Axios.new({ baseURL = "https://openexchangerates.org/api" })

local function fetchExchangeRates(callback)
	task.spawn(function()
		local response = axios:get("/latest.json?app_id=your_app_id", {}, function(response)
			if response.status == 200 then
				local data = response.data
				local usdToKrw = data.rates.KRW
				print("1 USD = " .. usdToKrw .. " KRW")
				callback(true) 
			else
				print("now status failed. : ", response.status)
				callback(false) 
			end
		end)
	end)
end
fetchExchangeRates(function(success)
	if success then
		print("sucess!")
	else
		print("failed")
	end
end)
