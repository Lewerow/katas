var machine = require("./machine");
var http = require("http");
var fs = require("fs");

function prettyPrint(withdrawals) {
    console.log("There you go: ");
    var any = false;
    for(var i = 0; i < withdrawals.length; ++i) {
        if(withdrawals[i] > 0) {
            any = true;
            console.log(`- ${withdrawals[i]}x$${machine.notes[i]} note`);
        }
    }
    if(!any) {
        console.log("Sorry to hear you don't want to withdraw after all");
    }
}

function convert(withdrawals) {
    var result = {};
    for(var i = 0; i < withdrawals.length; ++i) {
        if(withdrawals[i] > 0) {
            result[machine.notes[i]] = withdrawals[i];
        }
    }
    return result;
}

var args = process.argv.concat();

var withdraw;
if(args.includes("--fast")) withdraw = machine.fastWithdraw; else withdraw = machine.withdraw;

if(args.includes("--run-server")) {
    // use http, because we don't want to generate keys, certificates etc. for this simple exercise
    var server = http.createServer(function (req, res) {
        if(req.url === "/index.html") {
            var page = fs.readFileSync(__dirname + "/public/index.html");
            res.writeHead(200, {"Content-Type": "text/html; charset=UTF-8"});
            res.write(page, 'binary');
            res.end();
        } else if(req.url.startsWith("/withdraw")) {
            try {
                var amount = /\.*?amount=([0-9]*)/.exec(req.url);
                var withdrawal = withdraw(Number.parseInt(amount[1]));
                res.writeHead(200, {"Content-Type": "application/json; charset=UTF-8"});
                res.write(JSON.stringify(convert(withdrawal)));
            } catch(err) {
                res.writeHead(err.msg && 400 || 500, {"Content-Type": "text/plain; charset=UTF-8"});
                res.write(err.msg || "");
            }

            res.end();
        } else {
            res.writeHead(404);
            res.end();
        }
    });

    server.on('clientError', (err, socket) => {
        socket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
    });

    server.listen(8080);
} else {
    var withdrawal;
    var amount = args[args.length - 1];
    try {
        amount = Number.parseInt(amount)
    } catch {
        console.error(`Provided amount - ${amount} - is not an integer. Please provide integer number`);
        process.exit(1);
    }
    try {
        withdrawal = withdraw(amount);
        prettyPrint(withdrawal);
    } catch (err) {
        console.error(`Failed to withdraw: ${err.msg}`);
    }
}