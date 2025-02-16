local Axios = require("../luaxios")
local axios = Axios.new({
	baseURL = "https://jsonplaceholder.typicode.com", 
	timeout = 10, 
	retryCount = 3, 
	retryDelay = 1, 
})

axios:get("/todos/1", nil, function(response)
	if response.status == 200 then
		print("Nice!")
		print("data:", response.data)
	else
		print("error gg.. :", response.error)
	end
end)
