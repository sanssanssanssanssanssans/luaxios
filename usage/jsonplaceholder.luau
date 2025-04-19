
local Axios = require("pathtoluaxios")
local axios = Axios.new({
	baseURL = "https://jsonplaceholder.typicode.com", 
	timeout = 10, 
	retryCount = 3, 
	retryDelay = 1, 
})

axios:get("/todos/1")
	:Then(function(response)
		print("Nice!")
		print("data:", response.data)
	end)
	:Catch(function(err)
		print("error gg.. :", err.error)
	end)
