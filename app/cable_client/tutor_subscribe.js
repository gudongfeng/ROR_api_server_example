
const WebSocket = require('ws');

var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0dXRvcl9pZCI6MSwiZXhwIjoxNTM5NzQ3ODk3fQ.UsFgzFEln4ynZv5tPJ6lhUOEc7jJ32ykbLYg0HoCDV0";
var options = {
    headers: {
        "Authorization" : "JWT " + token
    }
};

const ws = new WebSocket("ws://localhost:3000/cable?type=tutor", options);

var tutor_subscribe = {"command":"subscribe",
                       "identifier":"{\"channel\":\"TutorChannel\"}"};

ws.onopen = function() {
  ws.send(JSON.stringify(tutor_subscribe));
};

var accept = {"command":"message",
              "identifier":"{\"channel\":\"TutorChannel\"}",
              "data":"{\"action\":\"response\", \"response\":\"accept\"}"};

ws.onmessage = function(e) {
  var res = JSON.parse(e.data);
  if (res.identifier && res.message) {
    // append the res.message to accept data
    accept.data = JSON.stringify(Object.assign(JSON.parse(accept.data), res.message))
    console.log(accept);
    console.log(res.message);
    // ws.send(JSON.stringify(accept))
  }
};