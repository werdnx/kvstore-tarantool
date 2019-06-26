local dao = require('db')
local log = require('log')
local httpd = require('http.server')
local SERVER_IP = os.getenv('SERVER_IP')

function put(key, value)
    dao:put(key, value)
    return {'OK'}
end

function get(key)
    return {dao:get(key)}
end

function delete(key)
    deleted = dao:delete(key)
    return {deleted}
end

local function postHandler(req)
    log.info('Recieved POST')
    if req:post_param('method') == 'get' then
        return get(req:post_param('key'))
    elseif req:post_param('method') == 'put' then
        return put(req:post_param('key'),req:post_param('value'))
    elseif req:post_param('method') == 'delete' then
        return delete(req:post_param('key'))
    end
end

function main()
    local server = httpd.new(SERVER_IP, 8080)
    server:route({ path = '/kv'}, postHandler)
    server:start()
end

main()
