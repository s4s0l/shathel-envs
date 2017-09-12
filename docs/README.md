
## Digital Ocean

Check why sth is dropped:

tail -f /var/log/kern.log | grep IPTables-Dropped


RexRay:
docker plugin install rexray/dobs DOBS_REGION=nyc1 DOBS_TOKEN=XXXX --grant-all-permissions  --alias shrex   