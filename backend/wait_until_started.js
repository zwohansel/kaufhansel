function waitUntilDBIsUp(port, timeout) {
    for (i=0;i<60;i++)
    {
        var conn = null;
        try
        {
            conn = new Mongo("localhost:" + port);
            return;
        }
        catch(Error)
        {
        }
        print("Waiting until db " + port + " is up and running...")
        sleep(1000);
    }
}

waitUntilDBIsUp(27017)
waitUntilDBIsUp(27018)
waitUntilDBIsUp(27019)


