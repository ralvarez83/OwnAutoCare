// Polyfill/Mock Web API objects for Node.js environment (Jest)
if (typeof global.Request === 'undefined') {
    console.log('Polyfilling Request, Response, Headers, URL...');
    global.Request = require('node-fetch').Request;
    global.Response = require('node-fetch').Response;
    global.Headers = require('node-fetch').Headers;
    global.URL = require('url').URL; // o global.URL = require('whatwg-url').URL;
    console.log('Polyfilling done.');
  } else {
    console.log('Request, Response, Headers, URL already defined.');
  }
