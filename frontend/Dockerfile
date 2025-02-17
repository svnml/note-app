# Imagen base de Node.js
FROM node:22.13

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar archivos del frontend
COPY package.json package-lock.json ./
RUN npm install

# Copiar el código fuente
COPY . .

# Construir la aplicación
RUN npm run build

# Servir con un servidor web ligero
RUN npm install -g serve

EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]
