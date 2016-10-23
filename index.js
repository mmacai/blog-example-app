const express = require('express');
const axios = require('axios');
const app = express();
const PORT = process.env.PORT || 5000;

app.set('port', PORT);

app.get('/', (request, response) => {
    response.send('Hello World!');
});

app.get('/service', (request, response) => {
    const url = process.env.SERVICE_URL || 'http://localhost:4000';

    axios(url)
    .then((data) => {
        response.send(`Hello from: ${data.data}`);
    })
    .catch((err) => {
        response.send(err);
        throw err;
    });
});

app.listen(app.get('port'), () => {
    console.log(`Node app is running at localhost: ${app.get('port')}`);
});
