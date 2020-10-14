# ChunkedTestServer

A dummy server that sends chunked responses that contain JSON objects.

### Build 

```bash
docker build --rm -t chunked_test_server .
```

### Run 

```bash
docker run --rm -p 4001:4001 chunked_test_server
```

### Test with curl

Limit to 10 rows: `curl http://localhost:4001/chunks?rows=10`
Run forever: `curl http://localhost:4001/chunks`