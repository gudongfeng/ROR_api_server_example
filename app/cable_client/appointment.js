// Student subscribes to student channel
const program   = require('commander');
const { prompt } = require('inquirer');
const WebSocket = require('ws');
var ws;
var student_id;
var plan_id;

const request_question = [
  {
    type: 'input',
    name: 'plan_id',
    message: 'Enter plan id (1, 2 or 3) ..'
  }
]

const student_option = [
  {
    type: 'input',
    name: 'options',
    message: 'Choose an option (e: extend call, c: cancel request) ..'
  }
]

const answer_question = [
  {
    type: 'input',
    name: 'response',
    message: 'accept or decline? ..'
  }
]

// Args: 
//  Token: student or tutor token
//  Type: 'Student' or 'Tutor'
var subscribe = function(token, type) {
  var options = { headers: { "Authorization" : "JWT " + token } };
  var subscribe = { "command":"subscribe",
                    "identifier":"{\"channel\":\"" + type + "Channel\"}" };
  ws = new WebSocket("ws://localhost:3000/cable?type=" + type.toLowerCase() + "", options);
  ws.onopen = function() {
    ws.send(JSON.stringify(subscribe)); 
    console.log("\nDEBUG: Subscribe to the " + type + " channel");
  }

  ws.onmessage = function(e) {
    var res = JSON.parse(e.data);
    if (res.identifier && res.message) {
      student_id = res.message.message.student_id
      plan_id = res.message.message.plan_id
      console.log("\nDEBUG: " + JSON.stringify(res.message));
    }
  };
}

var send_request = function(data){
  var plan_id = data.plan_id;
  var request = { "command":"message",
                  "identifier":"{\"channel\":\"StudentChannel\"}",
                  "data":"{\"action\":\"request\",\"plan_id\":" + plan_id + "}" };
  ws.send(JSON.stringify(request));
  console.log('\nDEBUG: Send appointment request');
  prompt(student_option).then(student_function);
}

var student_function  = function(data){
  var choice = data.options;
  if (choice == 'c') {
    console.log("\nCancelling the request");
    var request = { "command":"message",
                    "identifier":"{\"channel\":\"StudentChannel\"}",
                    "data":"{\"action\":\"cancel\"}" };
    ws.send(JSON.stringify(request));
  } else if (choice == 'e') {
    console.log("\nExtend the call");
    var request = { "command":"message",
                    "identifier":"{\"channel\":\"StudentChannel\"}",
                    "data":"{\"action\":\"extend\"}" };
    ws.send(JSON.stringify(request));
  } else {
    console.log("\nInvalid input value")
    prompt(student_option).then(student_function);
  }
}

var answer_request = function(data){
  var answer  = data.response;
  var message = { student_id: student_id, plan_id: plan_id }
  var data = { action: "response", response: data.response, message: message };
  var accept = { "command":"message",
                          "identifier":"{\"channel\":\"TutorChannel\"}",
                          "data":JSON.stringify(data) };
  ws.send(JSON.stringify(accept));
}

program
  .version('0.0.1')
  .description('Student make an appointment');

program
  .command('request')
  .alias('r')
  .description('Make an appointment request')
  .action(() => {
    // Student subscribe to the student channel
    var token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdHVkZW50X2lkIjoxLCJleHAiOjE1Mzk3NDc4NTF9.DAHD1ebSI-G12geQBjbl9r2DuYanbTBGjTb-hMJu6-s';
    subscribe(token, 'Student')
  })
  .action(() => {
    prompt(request_question).then(send_request);
  });

program
  .command('answer')
  .alias('a')
  .description('Tutor answer to the student request')
  .action(() => {
    // Tutor go online, subscribe to the tutor channel
    var token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0dXRvcl9pZCI6MSwiZXhwIjoxNTM5NzQ3ODk3fQ.UsFgzFEln4ynZv5tPJ6lhUOEc7jJ32ykbLYg0HoCDV0';
    subscribe(token, 'Tutor')
  })
  .action(() => {
    prompt(answer_question).then(answer_request);
  });


if (!process.argv.slice(2).length || !/[arudl]/.test(process.argv.slice(2))) {
  program.outputHelp();
  process.exit();
}
program.parse(process.argv);