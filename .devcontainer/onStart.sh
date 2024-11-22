#! /bin/sh
echo ""
echo "Limpiando procesos de la sesión anterior"
pkill -f "mariadb|nginx|inspect|ng|app\.js"
echo "Hecho"

echo ""
echo "Actualizando dependencias de Back y Front"
(cd /workspace/MinInteriorBACK && npm i) &
(cd /workspace/MinInteriorFRONT && npm i) &
wait
echo "Finalizada la actualización"

echo ""
echo "Inicializando Base de datos"
mariadbd-safe --user=root &
sleep 10
echo "Base de datos iniciada"

echo ""
echo "Inicializando servicios"
nginx
concurrently -n Back,Front -c bgBlue.bold,bgMagenta.bold "cd /workspace/MinInteriorBACK && npm run start" "cd /workspace/MinInteriorFRONT && npm run start:devenv"

echo "Servicios iniciados"
