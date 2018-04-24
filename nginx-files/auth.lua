local secret = os.getenv("API_SECRET")

assert(secret ~= nil, "Environment variable API_SECRET not set")

local M = {}

function M.validate()
    local auth_header = ngx.var.http_Authorization

    if auth_header == nil then
      ngx.log(ngx.WARN, "No Authorization header")
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
    else

      -- require Bearer token
      i, j, token = string.find(auth_header, "Bearer%s+(.+)")
      if token == nil then
        ngx.log(ngx.WARN, "Missing token")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
      else
        ngx.log(ngx.WARN, "Got token from auth header: " .. token)

        if secret ~= token then
          ngx.log(ngx.WARN, "Invalid token when compared against " .. secret)
          ngx.exit(ngx.HTTP_UNAUTHORIZED)
        end
      end
    end

    return true
end

return M
