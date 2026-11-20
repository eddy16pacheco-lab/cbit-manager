#!/bin/bash
# Lanzador de cbit_manager: arranca el servidor local y abre el navegador.
# Cerrar esta ventana SI apaga el servidor (es la que lo mantiene corriendo).

# Cambia al directorio donde se encuentra este script
cd "$(dirname "$0")"

echo "Iniciando cbit_manager..."

# Abre el navegador 3 segundos después en segundo plano, 
# mientras el servidor arranca en esta misma ventana
(sleep 3 && xdg-open "http://localhost:3000") &

# Arranca el servidor de Node.js
node server.js

echo ""
echo "cbit_manager se detuvo."
read -p "Presiona [Enter] para salir..."
