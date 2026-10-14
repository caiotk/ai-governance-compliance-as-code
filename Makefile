# AI Governance Compliance as Code — developer entry points.
#   make setup      install Python deps and report missing CLIs
#   make build      validate the catalogue and regenerate derived files
#   make check      fail if generated files are stale (what CI runs first)
#   make gate       evaluate systems/*.yaml (SYSTEMS=... to override)
#   make inventory  build the inventory (docs/INVENTORY.md, .csv, .json)
#   make report     audit pack for every system in systems/ (REPORT_DIR=...)
#   make test       everything CI runs; TF=0 skips Terraform
#   make api        run the read-only API on :8080
#   make mcp        run the MCP server on stdio
.DEFAULT_GOAL := help
PY       ?= python3
SYSTEMS  ?= systems/*.yaml
TF       ?= 1
REPORT_DIR ?= build/reports
OPA_VERSION  := 1.21.2
TF_VERSION   := 1.13.4
BICEP_VERSION := 0.48.1

help:
	@sed -n 's/^#   //p' Makefile

setup:
	$(PY) -m pip install -r requirements.txt
	@for t in opa terraform bicep cfn-lint; do \
	  if command -v $$t >/dev/null 2>&1; then printf '  %-10s %s\n' $$t "$$(command -v $$t)"; \
	  else printf '  %-10s MISSING (see .devcontainer/Dockerfile for pinned install)\n' $$t; fi; done

build:
	$(PY) tools/build.py

check:
	$(PY) tools/build.py --check

gate:
	$(PY) tools/gate.py --markdown build/gate.md --sarif build/gate.sarif $(SYSTEMS)

inventory:
	$(PY) tools/inventory.py --out-dir docs

report:
	$(PY) tools/report.py --out-dir $(REPORT_DIR) $(SYSTEMS)

reviews:
	$(PY) tools/reviews.py --days 30

test:
ifeq ($(TF),1)
	tools/ci.sh
else
	tools/ci.sh --skip-terraform
endif

api:
	$(PY) api/server.py --port 8080

mcp:
	$(PY) mcp/server.py

clean:
	rm -rf build __pycache__ */__pycache__ */*/__pycache__

.PHONY: help setup build check gate inventory report reviews test api mcp clean
