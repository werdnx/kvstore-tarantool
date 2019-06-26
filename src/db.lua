local log = require('log')
SPACE_NAME = "kv_space"
box.cfg { listen = 3301 }
s = box.schema.space.create(SPACE_NAME, { if_not_exists = true,
                                          format = ({
                                              { name = 'key', type = 'string' },
                                              { name = 'value', type = 'string' }
                                          }) })
log.info('space created')
s:create_index('primary', {
    type = 'hash',
    parts = { 'key' },
    if_not_exists = true
})
log.info('index created')

local dao = {
    put = function(self, key, value)
        s:upsert({key, value}, {{ '=', 2, value }})
    end,

    get = function(self, key)
        return s:select(key)
    end,

    getAll = function(self)
        return s:select()
    end,

    delete = function(self, key)
        return s:delete(key)
    end
}

return dao