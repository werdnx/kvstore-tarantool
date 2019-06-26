local dao = require('db')

function put(request, key, value)
    dao:put(key, value)
    return {'OK'}
end

function get(request, key)
    return {dao:get(key)}
end

function getAll(request)
    return {dao:getAll()}
end

function delete(request, key)
    deleted = dao:delete(key)
    return {deleted}
end