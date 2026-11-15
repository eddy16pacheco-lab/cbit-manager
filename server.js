const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const session = require('express-session');
const cors = require('cors');
const path = require('path');
const { port, sessionSecret } = require('./config/app');

const app = express();
const httpServer = http.createServer(app);
const io = new Server(httpServer, {
    cors: { origin: true, credentials: true }
});

// Se expone la instancia de Socket.IO para que cualquier controlador o
// middleware pueda emitir eventos en tiempo real (app.get('io')).
app.set('io', io);

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

io.on('connection', (socket) => {
    // Cada cliente conectado recibe automáticamente las actualizaciones globales.
    socket.on('disconnect', () => {});
});

httpServer.listen(port, () => {
    console.log(`✅ CBIT Manager corriendo en http://localhost:${port}`);
    console.log(`🔌 Socket.IO listo para actualizaciones en tiempo real`);
});
