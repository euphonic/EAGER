// just for firm website pages
use FirmDB
db.createUser({ 
	user: "scrapy", 
	pwd: "eager", 
	roles: [{ "role":"readWrite", "db":"FirmDB"}]
})

// general EAGER db
use EAGER
db.createUser({
        user: "bing" ,
        pwd: "eager",
        roles: [{ "role":"readWrite", "db":"EAGER"}]
})
