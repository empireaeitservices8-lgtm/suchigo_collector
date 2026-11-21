# Suchigo Collector

## Overview
The **Suchigo Collector** repository contains a data‑collection utility that scrapes and aggregates product information from the Suchigo marketplace.  It is built with **Python 3.11** and uses `requests` and `beautifulsoup4` for web scraping, with optional integration to a PostgreSQL database for persistence.

## Repository Structure
```
suchigo_collector/
├─ src/                # Source code package
│   ├─ __init__.py
│   ├─ collector.py   # Core scraper implementation
│   └─ utils.py       # Helper functions (logging, parsing)
├─ tests/              # Unit and integration tests
│   └─ test_collector.py
├─ requirements.txt    # Python dependencies
├─ Dockerfile          # Container build instructions
├─ .gitignore          # Ignored files
└─ PROJECT_DOCUMENTATION.md   # This document
```

## Prerequisites
- **Python 3.11+**
- **pip** (or use `uv`/`poetry` if preferred)
- Optional: **Docker** if you wish to run the collector in a container.

## Setup
1. **Create a virtual environment** (recommended)
   ```bash
   python -m venv venv
   source venv/bin/activate   # Windows: venv\Scripts\activate
   ```
2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```
3. **Configure environment variables**
   Create a `.env` file in the project root with the following keys (adjust values as needed):
   ```
   SUCHIGO_BASE_URL=https://www.suchigo.com
   DATABASE_URL=postgresql://user:password@localhost/suchigo
   ```

## Running the Collector
```bash
python -m src.collector --category electronics --output results.json
```
The script will fetch product listings for the specified category and write the results to `results.json`.

## Docker Usage
```bash
# Build the image
docker build -t suchigo-collector .

# Run the container (pass env vars as needed)
 docker run --rm \
   -e SUCHIGO_BASE_URL=https://www.suchigo.com \
   -e DATABASE_URL=postgresql://user:password@db/suchigo \
   suchigo-collector \
   python -m src.collector --category books --output /data/books.json
```

## Testing
```bash
pytest tests/
```
All tests should pass. Add new tests under `tests/` as you extend functionality.

## Contributing
1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/<description>
   ```
3. Make changes, ensure tests pass, and submit a Pull Request.

## License
This project is licensed under the **MIT License** – see the `LICENSE` file for details.

---
*Generated on $(Get-Date -Format "yyyy-MM-dd") by Antigravity AI assistant.*

