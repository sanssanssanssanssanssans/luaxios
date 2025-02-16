# luaxios

luaxios is a Lua library for making asynchronous HTTP requests and handling JSON responses. This library is based on `HttpService` and supports multiple HTTP methods for communication.

## Installation 

go to main.luau, then copy code and go to serverscriptservice, next make modulescript name "luaxios". then, paste code.

# usage

1. create an luaxios Instance

``` luau

local axios = Axios.new({
    baseURL = "https://example.com",  -- base url
    timeout = 5000,  -- Set timeout (5 seconds)
    retryCount = 3,  -- Set maximum retry attempts
    retryDelay = 1   -- Set delay between retries (1 second)
})

```

2. sending http requsets.

Get request :
```luau
axios:get("/path/to/resource", {}, function(response)
    if response.status == 200 then
        print("Successfully received data!")
        print(response.data)
    else
        print("Error occurred: " .. response.status)
    end
end)
```

POST request

```luau
local data = { key = "value" }
axios:post("/path/to/resource", data, {}, function(response)
    if response.status == 200 then
        print("POST request successful")
        print(response.data)
    else
        print("Error occurred: " .. response.status)
    end
end)
```

other methods (PATCH,PUT,DELETE)

```luau
axios:patch("/path/to/resource", data, {}, function(response) end)
axios:put("/path/to/resource", data, {}, function(response) end)
axios:delete("/path/to/resource", {}, function(response) end)
```

3. Handlling Responses and Errors

luaxios returns the response in a callback function. If the status code is in the 200s, it indicates a successful request, otherwise, an error occurred.

Response Object:
status: HTTP status code (e.g., 200, 404, 500, etc.)
data: The JSON response data (either object or string)
headers: The response headers (for debugging purposes, etc.)
error: Error message if the request fails

Options
When creating an instance using Axios.new, you can set the following options:

baseURL: The base URL for requests.
timeout: The timeout for requests (in milliseconds).
retryCount: The maximum number of retries for failed requests.
retryDelay: The delay (in seconds) between retries.

Retry Logic
luaxios includes built-in retry functionality. You can configure the number of retries and the delay between retries using the retryCount and retryDelay options. For example, set up 3 retries with a 2-second delay:
