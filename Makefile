
.PHONY: bash tests all

bash:
	./scripts/collect.sh
	./scripts/preprocessed.sh
	./scripts/train.sh

tests:
	uv run pytest tests/test_collect.py
	uv run pytest tests/test_preprocessed.py
	uv run pytest tests/test_model.py

all: bash tests

