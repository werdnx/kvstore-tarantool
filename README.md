# KVSTORE

A key value store with REST API implemented using tarantool. It has basic auth mechanism, RPS limiting and able to keep json values.

## Basic auth

It assumes user and base64 encoded password will comes in authorization header.
There is special store for users, it keeps user id(name), sha256 hashed passwor and permissions for REST operations. It is possible to assign separate permissions for each REST operation.
By default there is user admin with password adminpwd with all permissions.

## RPS limiting
By default RPS limit value = 20. It can be changed in docker-compose.yml file. 

## STORAGE

For keeping json values used https://github.com/tarantool/document. It allows to work with not determined json schema.

## HTTP SERVER 
For http server used https://github.com/tarantool/http. It is listen 8080 port 

## REST API
HTTP code 401 will be returned in cases:
* Wrong user
* Wrong password 
* There is no **authorization** header

HTTP code 429 will be returned if RPS limit exceeded

### GET 
Returns data by key.
Example of GET request:
~~~~ 
GET /kv/123 HTTP/1.1
Host: 127.0.0.1:8080
Authorization: Basic YWRtaW46YWRtaW5wd2Q=
User-Agent: PostmanRuntime/7.15.0
Accept: */*
Cache-Control: no-cache
Postman-Token: 0367e556-54ae-40ad-b356-b8a842a5e002,e2eabf43-23b5-42d4-a989-aff1c38162a4
Host: 127.0.0.1:8080
accept-encoding: gzip, deflate
Connection: keep-alive
cache-control: no-cache
~~~~ 
where 123 is key to find.
It will return null in case if key not found and json object otherwise f.e. **{"key":"123","value":{"c1":"cv1","c2":"cv2"}}**

## PUT
Inserts or updates data for given key.
Value should be passed in json format in request body.
Example of PUT request:
~~~~ 
 PUT /kv/123 HTTP/1.1
 Host: 127.0.0.1:8080
 Authorization: Basic YWRtaW46YWRtaW5wd2Q=
 Content-Type: text/plain
 User-Agent: PostmanRuntime/7.15.0
 Accept: */*
 Cache-Control: no-cache
 Postman-Token: 0655ad2b-702c-4f47-aed5-652ef13be504,8311187b-1afd-4344-9b41-009881a54b98
 Host: 127.0.0.1:8080
 accept-encoding: gzip, deflate
 content-length: 23
 Connection: keep-alive
 cache-control: no-cache
 
 {"c1":"cv1","c2":"cv2"}
~~~~
Expected response is HTTP 200 OK code.

## POST
Updates data for given value.
Value should be passed in json format in request body.
Example of PUT request:
~~~~ 
POST /kv/123 HTTP/1.1
Host: 127.0.0.1:8080
Authorization: Basic YWRtaW46YWRtaW5wd2Q=
Content-Type: text/plain
User-Agent: PostmanRuntime/7.15.0
Accept: */*
Cache-Control: no-cache
Postman-Token: 04093112-68ca-43fc-9cdb-c821a642651d,766c08ce-0431-4f52-8678-c3f84f3ba02a
Host: 127.0.0.1:8080
accept-encoding: gzip, deflate
content-length: 34
Connection: keep-alive
cache-control: no-cache

{"c1":"cv1","c2":"cv3","c3":"cv4"}
~~~~ 
Expected response is HTTP 200 OK code. Also it can return 404 code in case key not found.

## DELETE
Deletes data for given key.
Example of DELETE request:
~~~~ 
DELETE /kv/123 HTTP/1.1
Host: 127.0.0.1:8080
Authorization: Basic YWRtaW46YWRtaW5wd2Q=
User-Agent: PostmanRuntime/7.15.0
Accept: */*
Cache-Control: no-cache
Postman-Token: 91e1d682-8f03-4dc1-b30a-6fb1292c3818,e12008ef-2487-43b8-9453-1ba57820c728
Host: 127.0.0.1:8080
accept-encoding: gzip, deflate
content-length: 
Connection: keep-alive
cache-control: no-cache
~~~~
Expected response is HTTP 200 OK code. Also it can return 404 code in case key not found.
 
## HOW TO RUN
To run **kvstore** need execute following from project folder:
~~~~
docker-compose build
docker-compose up
~~~~
or run build_and_run.sh
After run server should be avaliable by URL http://127.0.0.1:8080/kv/:key

docker and docker-compose are required. 