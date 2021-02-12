print("Create initial user...");

conn = new Mongo();
db = conn.getDB("shoppingListApp");

db.shoppingListUser.insert(
    {
        "_id" : ObjectId("5ebc46c38855d8618faad2ed"),
        "username" : "test",
        "password" : "$2y$10$27Qcx8KRoFrIXtrVhKyFROW4avVFQzO0zxPE3Na5BtK3po6UzoCnW",
        "emailAddress" : "test@test.de"
    },
    {
        writeConcern: { w: 3, j: true, wtimeout: 60000 } // Wait until the insert has been written to disk and acknowledged by all three replicas
    }
);