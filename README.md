# demo-vault-ent-cluster

Once cluster is deployed, ssh to one of the nodes and init (vault operator init), this will unseal vault.  Next, login to the remaining nodes and restart vault.  This will get the rest of the nodes to auto-join the cluster.  This is necessary since the default settings do not automatically retry to join the cluster.   


# Doc Links
Route Tables - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

