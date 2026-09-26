require('dotenv').config();
module.exports = {
    port: process.env.PORT || 3000,
    sessionSecret: process.env.SESSION_SECRET || 'cbit_secret_2024',
    ubicacionPrincipal: 'CBIT Francisco de Miranda'
};
