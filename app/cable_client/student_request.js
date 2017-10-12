
// This is an example showing that student subscribes to the StudentChannel
//   and make a request to apply for appointment.

const WebSocket = require('ws');

var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdHVkZW50X2lkIjoxLCJleHAiOjE1Mzk3NDc4NTF9.DAHD1ebSI-G12geQBjbl9r2DuYanbTBGjTb-hMJu6-s";
var options = {
  headers: {
    "Authorization" : "JWT " + token
  }
};

const ws = new WebSocket("ws://localhost:3000/cable?type=student", options);

var subscribe = {"command":"subscribe",
                 "identifier":"{\"channel\":\"StudentChannel\"}"};
var request = {"command":"message",
               "identifier":"{\"channel\":\"StudentChannel\"}",
               "data":"{\"action\":\"request\",\"plan_id\":1}"};

ws.onopen = function() {
  ws.send(JSON.stringify(subscribe));
  ws.send(JSON.stringify(request));
};

ws.onmessage = function(e) {
  var res = JSON.parse(e.data);
  if (res.identifier && res.message) {
    console.log(res.message);
  }
};