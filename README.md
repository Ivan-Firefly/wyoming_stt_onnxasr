## Wyoming STT сервер для Home Assistant на базе [ONNX ASR](https://github.com/istupakov/onnx-asr)
#### Нацелен на русскоговорящую аудиторию (из многообразия моделей рекомендую `gigaam-v3`)
For English-speaking users, the Parakeet models (e.g., `nemo-parakeet-tdt-0.6b-v2`) are recommended, `canary-1b-v2` is slightly higher quality, but 4 times slower.

### Доступные модели:
```
gigaam-v2-ctc
gigaam-v2-rnnt
gigaam-v3-ctc                 # теперь это база, int8 - 220 мб, full - 865мб
gigaam-v3-rnnt
gigaam-v3-e2e-ctc             # e2e модели с пунктуацией
gigaam-v3-e2e-rnnt
alphacep/vosk-model-ru        # int8 - 70мб, full - 260мб, ещё быстрее но WER хуже
alphacep/vosk-model-small-ru  # 25мб/90мб, в аддоне HA исользуется v0.22, здесь v0.54
nemo-fastconformer-ru-ctc
nemo-fastconformer-ru-rnnt
nemo-parakeet-ctc-0.6b        # eng / int8 - 620мб
nemo-parakeet-rnnt-0.6b       # eng
nemo-parakeet-tdt-0.6b-v2     # eng
nemo-parakeet-tdt-0.6b-v3     # multilingual / may work inconsistently, as automatic language detection is used for each request
nemo-canary-1b-v2             # multilingual / int8 - 980мб; The transcription language is matched with the agent language.

whisper-base                  # комплектные варианты шёпота не интересны, так как есть faster-whisper
onnx-community/whisper-tiny
onnx-community/whisper-base
onnx-community/whisper-small
onnx-community/whisper-large-v3-turbo
```
`parakeet-v3` и `canary-1b-v2` поддерживают следующие языки: `"bg", "hr", "cs", "da", "nl", "en", "et", "fi", "fr", "de", "el", "hu", "it", "lv", "lt", "mt", "pl", "pt", "ro", "sk", "sl", "es", "sv", "ru", "uk"`
