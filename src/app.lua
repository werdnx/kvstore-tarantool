local dao = require('db')
local check = require('check')
local httpd = require('http.server')
local SERVER_IP = os.getenv('SERVER_IP')
local json = require('json')
local test = require('test')
local log = require('log')


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
    local obj = get(req:stash('key'))
    if obj == nil then
        return response(req, 404, 'Key ' .. req:stash('key') .. ' not found')
    else
        delete(req:stash('key'))
        return emptyResponse(req)
    end
end

local function postHandler(req)
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

local function getHandler(req)
    return req:render({ text = json.encode(get(req:stash('key'))) })
end

local function putHandler(req)
    if req:stash('key') == nil or req:json() == nil then
        return response(req, 400, 'Bad params key or value is null')
    else
        put(req:stash('key'), req:json())
        return emptyResponse(req)
    end
end

local function handler(req)
    if check:rps() == false then
        return response(req, 429, 'Too Many Requests')
    elseif check:auth(req) == false then
        return response(req, 401, 'Unauthorized')
    else
        if req.method == 'POST' then
            return postHandler(req)
        elseif req.method == 'PUT' then
            return putHandler(req)
        elseif req.method == 'GET' then
            return getHandler(req)
        elseif req.method == 'DELETE' then
            return deleteHandler(req)
        else
            return response(req, 405, 'Method Not Allowed')
        end
    end
end

function main()
    local server = httpd.new(SERVER_IP, 8080)
    server:route({ path = '/kv/:key' }, handler)
    server:start()
    test:doTests()
end

main()
