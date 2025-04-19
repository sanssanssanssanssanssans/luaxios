# luaxios

luaxios is a lightweightm Axios-inspired HTTP client for Luau. It uses a Promise-based design.

## 📦 Components

- `luaxios.luau`: The main client with methods like `get`, `post`, `put`, `delete`, and support for retries, timeouts, and baseURL.
- `Promise.luau`: A minimal Promise implementation for async-style flow.
- `XMLParser.luau`: A simple XML-to-table parser for handling XML responses.

## 🚀 Features

- Axios-like API (`get`, `post`, `put`, `delete`)
- Promise-based request handling
- JSON and XML response parsing
- Automatic retry on failure
- Timeout management
- Customizable headers
- Built-in cookie parsing

## 🔧 Installation

Place the following modules in your Roblox project.
Then require them in your script.

## 🛠️ Usage

### Initalize the client.

```luau
local Axios = require(path_to_LuAxios.Axios)
local axios = Axios.new({
	baseURL = "https://api.example.com",
	headers = {
		["Content-Type"] = "application/json",
	},
	timeout = 5,        -- optional
	retryCount = 3,     -- optional
	retryDelay = 1,     -- optional
	debug = false,      -- optional
})
```

### Make a GET request

```luau
axios:get("/users")
	:Then(function(response)
		print("Success!", response.data)
	end)
	:Catch(function(err)
		warn("Failed:", err.error)
	end):Finally(function(err)
        warn("zzzz")
    end)
```

### Make a POST request
```luau
axios:post("/users", { name = "Alice" })
	:Then(function(response)
		print("User created:", response.data)
	end)
	:Catch(function(err)
		warn("Error:", err.error)
	end):Finally(function(err)
        warn("zzzz")
    end)
```

### ⚙️ Additional Methods

```text
axios:setTimeout(seconds)
axios:setHeaders({ key = value, ... })
axios:addHeader(key, value)
axios:clearHeaders()
axios:setBaseURL(url)
axios:setRetryConfig(retryCount, retryDelay)
```

### 🍪 Get Cookies

```luau
local cookies = axios:getCookies(response)
```

## License

MIT License. Use freely, modify as needed. </br>
Contributions and improvements welcome! </br>
Let me know if you want a Korean version alongside it or want to publish this as a GitHub project with a proper example project included!
