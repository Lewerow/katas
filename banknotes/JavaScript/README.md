## Running

This project has no dependencies other than a recent version of Node.js (tested on v10.10).

Main operations:

 - testing via `npm test`
 - running CLI via `node index.js` with amount as the last argument
 - runing HTTP server via `node index.js --run-server`
 
Both server and CLI can be started in "fast" mode (using `--fast` switch). 
The used algorithm is not necessarily faster (was not benchmarked), but is slightly
different, and may be better for some cases. Results are exactly the same, so it's fine. 

Example commands:

```sh

node index.js 500
node index.js 534
node index.js --fast 123
node index.js --run-server
node index.js --run-server --fast
```

For running calls via HTTP server you need to have a working network connection,
as some libraries (MetroUI and jQuery) are fetched from CDNs. Server will be started on port 8080