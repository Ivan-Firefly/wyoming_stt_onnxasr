FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Source code is provided by the build context (for example, your fork checked
# out by GitHub Actions). No git clone is performed inside the image build.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/wyoming_stt_onnxasr

# Copy requirements first to keep dependency installation cached when only
# application source files change.
COPY requirements.txt ./requirements.txt
RUN python -m pip install --upgrade pip \
    && python -m pip install -r requirements.txt

# Build context should be the root of your wyoming_stt_onnxasr repository.
# models/ is excluded by .dockerignore and mounted at runtime by Compose.
COPY . .

# The upstream server exposes only --model (a model identifier). Add --model-dir
# so onnx-asr can load/cache files in a host-mounted directory: load_model(model, path=...).
RUN python - <<'PY'
from pathlib import Path

source_file = Path("/opt/wyoming_stt_onnxasr/wyoming_onnxasr/__main__.py")
source = source_file.read_text(encoding="utf-8")

parser_anchor = '    parser.add_argument(\n        "--quantization",'
parser_replacement = (
    '    parser.add_argument(\n'
    '        "--model-dir",\n'
    '        default=None,\n'
    '        help="Path to a local directory containing model files",\n'
    '    )\n'
    + parser_anchor
)
if parser_anchor not in source:
    raise SystemExit("Could not patch CLI: --quantization argument anchor not found")
source = source.replace(parser_anchor, parser_replacement, 1)

load_anchor = (
    '    model = onnx_asr.load_model(\n'
    '        args.model,\n'
    '        quantization=args.quantization,\n'
    '        providers=providers\n'
    '    )'
)
load_replacement = (
    '    model = onnx_asr.load_model(\n'
    '        args.model,\n'
    '        path=args.model_dir,\n'
    '        quantization=args.quantization,\n'
    '        providers=providers\n'
    '    )'
)
if load_anchor not in source:
    raise SystemExit("Could not patch CLI: onnx_asr.load_model call anchor not found")
source = source.replace(load_anchor, load_replacement, 1)
source_file.write_text(source, encoding="utf-8")
PY

EXPOSE 10305

# docker-compose.yaml supplies the chosen model, directory and quantization.
