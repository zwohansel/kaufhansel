print("Initialize replica set...");

rsconf = {
  _id: "rs0",
  members: [
    {
     _id: 0,
     priority: 1000,
     host: "localhost:27017"
    },
    {
     _id: 1,
     priority: 0,
     host: "localhost:27018"
    },
    {
     _id: 2,
     priority: 0,
     host: "localhost:27019"
    }
   ]
}

rs.initiate( rsconf )

for (i=0; i < 60; i++) {
    result = rs.status();

    //printjson(result);

    if (result.electionCandidateMetrics && result.electionCandidateMetrics.wMajorityWriteAvailabilityDate) {
        quit(0);
    }

    print("Waiting for replica set sync to complete...")
    sleep(1000)
}

quit(1);