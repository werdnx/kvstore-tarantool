local dao = require('db')
local log = require('log')
local httpd = require('http.server')
local SERVER_IP = os.getenv('SERVER_IP')
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

function badResponse(req, status, message)
    local resp = req:render({ text = message })
    resp.status = status
    return resp
end

local function deleteHandler(req)
    local obj = get(req:stash('key'))
    if obj == nil then
        return badResponse(req, 404, 'Key ' .. req:stash('key') .. ' not found')
    else
        return req:render({text = delete(req:stash('key'))})
    end
end

local function postHandler(req)
    if req:stash('key') == nil or req:stash('value') == nil then
        return badResponse(req, 400, 'Bad params key or value is null')
    else
        local obj = get(req:stash('key'))
        if #obj == 0 then
            return badResponse(req, 404, 'Key ' .. req:stash('key') .. ' not found')
        else
            put(req:stash('key'), req:stash('value'))
            return req:render({text = ''})
        end
    end
end

local function getHandler(req)
    return req:render({ text = json.encode(get(req:stash('key'))) })
end

local function putHandler(req)
    if req:stash('key') == nil or req:stash('value') == nil then
        return badResponse(req, 400, 'Bad params key or value is null')
    else
        put(req:stash('key'), req:stash('value'))
        return req:render({text = ''})
    end
end

function main()
    local server = httpd.new(SERVER_IP, 8080)
    server:route({ path = '/kv/:key/:value', method = 'POST' }, postHandler)
    server:route({ path = '/kv/:key/:value', method = 'PUT' }, putHandler)
    server:route({ path = '/kv/:key', method = 'GET' }, getHandler)
    server:route({ path = '/kv/:key', method = 'DELETE' }, deleteHandler)
    server:start()
end

main()
