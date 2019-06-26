local log = require('log')
doc = require('document')

SPACE_NAME = "kv_space_json"
box.cfg { listen = 3301 }
s = box.schema.space.create(SPACE_NAME, { if_not_exists = true })
log.info('space created')
doc.create_index(s, 'primary', { parts = { 'key', 'string' }, if_not_exists = true })
log.info('index created')

local dao = {
    put = function(self, key, value)
        s:put(doc.flatten(s,{key = key, value = value}))
    end,

    get = function(self, key)
        return doc.unflatten(s, s:get(key))
    end,

    delete = function(self, key)
        return doc.delete(s, { { '$key', '==', key } })
    end
}

return dao