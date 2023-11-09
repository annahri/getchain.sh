# getchain.sh

```
getchain.sh -- CLI wrapper for whatsmychaincert.com
 
Usage: getchain.sh <-c certfile|-h hostname> [-r]
 
Flags: 
 -c certfile  Get cert chain by certificate file.
 -h hostname  Get cert chain by hostname.
 -r           Include root certificate.
 
Note:
 Both -c and -h are mutually exclusive. If both are defined, the last one will be used.
 
Examples: 
 getchain.sh -c ./cert.pem -r
 getchain.sh -h yourdomain.com -r
```
