use admin
db.createUser({ 
	user: "sanjay" , 
	pwd: "eager", 
	roles: ["userAdminAnyDatabase", "dbAdminAnyDatabase", "readWriteAnyDatabase"]
})
