local log = require('log')
local json = require('json')
doc = require('document')

SPACE_NAME = "kv_space_json"
SPACE_NAME_USER = "kv_space_json"
box.cfg { listen = 3301 }
s = box.schema.space.create(SPACE_NAME, { if_not_exists = true })
s_user = box.schema.space.create(SPACE_NAME_USER, { if_not_exists = true,
                                                    format = ({
                                                        { name = 'name', type = 'string' },
                                                        { name = 'pwdHash', type = 'string' },
                                                        { name = 'value', type = 'string' }
                                                    }) })
log.info('space created')
doc.create_index(s, 'primary', { parts = { 'key', 'string' }, if_not_exists = true })
log.info('json index created')
s_user:create_index('primary', {
    type = 'hash',
    parts = { 'name' },
    if_not_exists = true
})
log.info('index created')
--default user
s_user:upsert({'admin'},{{'=',2,'7b18601f5caaa6dbbc7ad058ac54a25d30e7a508ce814c41f44ea5cabf9b3181'}, {'=',3,json.encode({ 'PUT', 'GET', 'DELETE', 'POST' })}})

local dao = {
    put = function(self, key, value)
        s:put(doc.flatten(s, { key = key, value = value }))
    end,

    get = function(self, key)
        return doc.unflatten(s, s:get(key))
    end,

    delete = function(self, key)
        return doc.delete(s, { { '$key', '==', key } })
    end,
    findUser = function(self, name)
        return s_user:get(name)
    end
}

return dao