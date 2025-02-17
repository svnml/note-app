#!/usr/bin/env bash
set -e

# Limpia si existe un package anterior
rm -rf package function.zip

# Crea una carpeta "package" donde pondrás tus dependencias
mkdir package
pip install --target package -r backend/requirements.txt

# Copia tu código Django dentro de "package"
cp -R backend/* package/

# (Opcional) Quitar archivos innecesarios (.pyc, __pycache__, etc.)
find package/ -name "*.pyc" -delete
find package/ -name "__pycache__" -delete

# Empaca todo en un zip
cd package
zip -r ../function.zip .
cd ..
