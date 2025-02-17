# Variables
PYTHON = python3
VENV = .venv
FRONTEND_DIR = frontend
BACKEND_DIR = backend

# Inicializar el repositorio
init:
	@echo "Inicializando entorno Django y React..."
	@cd $(BACKEND_DIR) && $(PYTHON) -m venv $(VENV) && source $(VENV)/bin/activate && pip install -r requirements.txt
	@cd $(FRONTEND_DIR) && npm install
	@echo "Repositorio inicializado."

# Construcción
build:
	@echo "Construyendo frontend..."
	@cd $(FRONTEND_DIR) && npm run build
	@echo "Preparando backend..."
	@cd $(BACKEND_DIR) && source $(VENV)/bin/activate && pip install -r requirements.txt
	@echo "Build completado."

# Migraciones y superusuario
migrate:
	@echo "Ejecutando migraciones..."
	@cd $(BACKEND_DIR) && source $(VENV)/bin/activate && python manage.py migrate

createsuperuser:
	@echo "Creando superusuario..."
	@cd $(BACKEND_DIR) && source $(VENV)/bin/activate && python manage.py createsuperuser

# Ejecución
run:
	@echo "Iniciando backend..."
	@cd $(BACKEND_DIR) && source $(VENV)/bin/activate && python manage.py runserver 0.0.0.0:8000 &
	@echo "Iniciando frontend..."
	@cd $(FRONTEND_DIR) && npm start

# Limpiar
clean:
	@echo "Eliminando archivos generados..."
	@rm -rf $(FRONTEND_DIR)/node_modules
	@rm -rf $(FRONTEND_DIR)/build
	@rm -rf $(BACKEND_DIR)/$(VENV)
	@find $(BACKEND_DIR) -name "*.pyc" -delete
	@find $(BACKEND_DIR) -name "__pycache__" -delete
	@echo "Limpieza completada."

.PHONY: init build migrate createsuperuser run clean
