const express = require('express');
const session = require('express-session');
const cors = require('cors');
const path = require('path');
const { port, sessionSecret } = require('./config/app');

const app = express();

app.use(cors({ origin: true, credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
    secret: sessionSecret,
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, maxAge: 8 * 60 * 60 * 1000 }
}));

app.use(express.static(path.join(__dirname, 'public')));
app.use('/api', require('./routes/api'));
app.use('/', require('./routes/web'));

app.listen(port, () => {
    console.log(`✅ CBIT Manager corriendo en http://localhost:${port}`);
});
