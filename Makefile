define HELP_TEXT
Использование: make [цель]

Цели:
	help          - показать все команды
	install       - установить зависимости
	lint          - проверить качество кода (flake8/ruff для Python, shellcheck для Bash)
	test          - запустить тесты
	run           - запустить приложение
	server-info   - запустить Bash-скрипт диагностики сервера
	docker-build  - собрать Docker образ
	docker-run    - запустить контейнер
	compose-up    - запустить Docker Compose
	compose-down  - остановить Docker Compose
	compose-logs  - просмотреть логи
	ansible-check - проверить Ansible playbook
	ansible-dry   - dry-run Ansible
	ansible-run   - запустить Ansible playbook
endef

.PHONY: help install lint test run server-info docker-build docker-run compose-up compose-down compose-logs ansible-check ansible-dry ansible-run

help:
	@echo "$$HELP_TEXT"
install:
	pip install -r ./app/requirements.txt
lint:
	pytest -v ./app
	flake8 -v ./app
	shellcheck ./scripts/server-info.sh
test:
	pytest ./app/tests/test_app.py -v
run:
	uvicorn app.main:app --port 5000
server-info:
	./scripts/server-info.sh 
docker-build:
	docker build . -t simple-app-image:latest
docker-run:
	docker run -d --name simple-app -p 5000:5000 simple-app-image:latest
compose-up:
	docker compose up -d
compose-down:
	docker compose down
compose-logs:
ansible-check:
	ansible-playbook --syntax-check -i ansible/hosts.yaml ansible/playbook.yaml
ansible-dry:
	ansible-playbook -i ansible/hosts.yaml ansible/playbook.yaml -CD
ansible-run:
	ansible-playbook -i ansible/hosts.yaml ansible/playbook.yaml
