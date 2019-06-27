---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by werdn.
--- DateTime: 27/06/2019 11:52
---
local dao = require('db')
local log = require('log')
local RPS = os.getenv('RPS')
local digest = require('digest')
local json = require('json')

lastCallTime = 0
requests = 0
maxRequests = tonumber(RPS)
local check = {
    rps = function(self)
        local result = true
        local callTime = os.time()
        if os.difftime(callTime, lastCallTime) == 0 then
            requests = requests + 1
            if requests > maxRequests then
                result = false
            end
        else
            requests = 1
        end
        lastCallTime = callTime
        return result
    end,

    auth = function(self, req)
        local auth = string.sub(req.headers['authorization'], 7)
        local decoded = digest.base64_decode(auth)
        local user, pwdHash = decoded:match("([^:]+):([^:]+)")
        local user = dao:findUser(user)
        if digest.sha256_hex(pwdHash) ~= user[2] then
            return false
        elseif string.find(user[3], req.method) == nil then
            return false
        else
            return true
        end
    end
}

return check