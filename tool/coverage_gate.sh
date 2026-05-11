#!/usr/bin/env bash
set -euo pipefail

# Gate global (LH/LF): evita merge sem nenhum teste e mantém um piso de linhas.
# Qualidade de regressão vem sobretudo de jornadas (integration_test), contratos
# de repositório e goldens — não use só este percentual como meta de "qualidade".
#
# Piso padrão: 50% de linhas cobertas (LH/LF do lcov global). Ajuste sem mudar
# este script definindo a variável de ambiente COVERAGE_MIN (ex.: no CI:
# `env: COVERAGE_MIN: "55"`).

if [[ ! -f coverage/lcov.info ]]; then
  echo "coverage/lcov.info not found. Run: flutter test --coverage"
  exit 1
fi

LF=$(awk -F: '/^LF:/{sum+=$2} END{print sum+0}' coverage/lcov.info)
LH=$(awk -F: '/^LH:/{sum+=$2} END{print sum+0}' coverage/lcov.info)

if [[ "${LF}" -eq 0 ]]; then
  echo "No LF entries in lcov (unexpected)."
  exit 1
fi

PCT=$((LH * 100 / LF))
MIN="${COVERAGE_MIN:-50}"

echo "Global line coverage: ${PCT}% (LH=${LH} LF=${LF}, minimum=${MIN}%)"

if [[ "${PCT}" -lt "${MIN}" ]]; then
  echo "Coverage below minimum. Raise tests or set COVERAGE_MIN to adjust."
  exit 1
fi
