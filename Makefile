VIRTUAL_ENV = $(shell echo $$VIRTUAL_ENV)

$(VIRTUAL_ENV):
	@[ -d $(VIRTUAL_ENV) ] || virtualenv $(VIRTUAL_ENV) --python=python3
	@touch $(VIRTUAL_ENV)

$(VIRTUAL_ENV)/bin/py.test: $(VIRTUAL_ENV) $(CURDIR)/requirements.txt
	@$(VIRTUAL_ENV)/bin/pip install -r $(CURDIR)/requirements.txt
	@touch $(CURDIR)/requirements.txt
	@touch $(VIRTUAL_ENV)/bin/py.test

.PHONY: provision
PTARGET  ?= vagrant
PINVENT  ?= $(CURDIR)/deploy/inventory.ini
PLAYBOOK ?= $(CURDIR)/deploy/setup.yml
provision:
	@echo "[make] Run Ansible provision"
	@chmod 600 $(CURDIR)/deploy/vagrant
	ansible-playbook $(PLAYBOOK) -i $(PINVENT) -l $(PTARGET) -vv

.PHONY: aws
aws:
	$(eval PTARGET := 'aws')
	$(eval PINVENT := 'aws.ini')

test: $(VIRTUAL_ENV)/bin/py.test
	$(VIRTUAL_ENV)/bin/py.test -xs tests.py
