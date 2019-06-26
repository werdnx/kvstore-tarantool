local dao = require('db')
local log = require('log')
local httpd = require('http.server')
local SERVER_IP = os.getenv('SERVER_IP')
local RPS = os.getenv('RPS')
local json = require('json')

function put(key, value)
    dao:put(key, value)
end

function get(key)
    return dao:get(key)
end

function delete(key)
    return dao:delete(key)
end

function response(req, status, message)
    local resp = req:render({ text = message })
    resp.status = status
    return resp
end

function emptyResponse(req)
    return response(req, 200, '')
end

local function deleteHandler(req)
    if checkRps() == false then
        return response(req, 429, 'Too Many Requests')
    else
        local obj = get(req:stash('key'))
        if obj == nil then
            return response(req, 404, 'Key ' .. req:stash('key') .. ' not found')
        else
            delete(req:stash('key'))
            return emptyResponse(req)
        end
    end
end

local function postHandler(req)
    if checkRps() == false then
        return response(req, 429, 'Too Many Requests')
    else
        if req:stash('key') == nil or req:json() == nil then
            return response(req, 400, 'Bad params key or value is null')
        else
            local obj = get(req:stash('key'))
            if obj == nil then
                return response(req, 404, 'Key ' .. req:stash('key') .. ' not found')
            else
                put(req:stash('key'), req:json())
                return emptyResponse(req)
            end
        end
    end
end

local function getHandler(req)
    if checkRps() == false then
        return response(req, 429, 'Too Many Requests')
    else
        return req:render({ text = json.encode(get(req:stash('key'))) })
    end
end

local function putHandler(req)
    if checkRps() == false then
        return response(req, 429, 'Too Many Requests')
    else
        if req:stash('key') == nil or req:json() == nil then
            return response(req, 400, 'Bad params key or value is null')
        else
            put(req:stash('key'), req:json())
            return emptyResponse(req)
        end
    end
end

lastCallTime = 0
requests = 0
maxRequests = tonumber(RPS)
function checkRps()
    local result = true
    local callTime = os.time()
    log.info('timediff ' .. os.difftime(callTime, lastCallTime))
    if os.difftime(callTime, lastCallTime) == 0 then
        requests = requests + 1
        log.info('RPS ' .. maxRequests)
        log.info('RPS req' .. requests)
        if requests > maxRequests then
            log.info('inside')
            result = false
        end
    else
        requests = 1
    end
    lastCallTime = callTime
    log.info('req ' .. requests)
    return result
end

function main()
    local server = httpd.new(SERVER_IP, 8080)
    server:route({ path = '/kv/:key', method = 'POST' }, postHandler)
    server:route({ path = '/kv/:key', method = 'PUT' }, putHandler)
    server:route({ path = '/kv/:key', method = 'GET' }, getHandler)
    server:route({ path = '/kv/:key', method = 'DELETE' }, deleteHandler)
    server:start()
end

main()
