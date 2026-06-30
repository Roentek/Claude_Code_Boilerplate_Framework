#!/usr/bin/env bash
# Install Stripe CLI for payments, webhooks, and local dev testing.
# Source: https://github.com/stripe/stripe-cli  Auth: stripe login
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v stripe &>/dev/null; then
  echo "✓ stripe already installed: $(stripe --version 2>&1 | head -1)"
  exit 0
fi

echo "  Installing Stripe CLI..."
if _is_windows; then
  if command -v winget &>/dev/null; then
    if _timeout 120 winget install --id Stripe.StripeCLI -e --silent; then
      echo "✓ stripe installed via winget"
      echo "  ⚠ Run 'stripe login' to authenticate before first use"
    else
      echo "⚠ winget install failed — try: scoop install stripe"
      echo "  Or download from: https://github.com/stripe/stripe-cli/releases"
    fi
  else
    echo "⚠ winget not found — download from: https://github.com/stripe/stripe-cli/releases"
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v brew &>/dev/null; then
    if _timeout 180 brew install stripe/stripe-cli/stripe; then
      echo "✓ stripe installed via brew"
      echo "  ⚠ Run 'stripe login' to authenticate before first use"
    else
      echo "⚠ brew install failed — run: brew install stripe/stripe-cli/stripe"
    fi
  else
    echo "⚠ brew not found — install from: https://brew.sh then: brew install stripe/stripe-cli/stripe"
  fi
else
  # Linux: official Stripe apt repo
  if curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public \
       | gpg --dearmor \
       | sudo tee /usr/share/keyrings/stripe.gpg >/dev/null 2>&1 && \
     echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" \
       | sudo tee /etc/apt/sources.list.d/stripe.list >/dev/null 2>&1 && \
     sudo apt-get update -qq >/dev/null 2>&1 && \
     _timeout 120 sudo apt-get install -y stripe >/dev/null 2>&1; then
    echo "✓ stripe installed via apt"
    echo "  ⚠ Run 'stripe login' to authenticate before first use"
  else
    echo "⚠ apt install failed — download from: https://github.com/stripe/stripe-cli/releases"
  fi
fi
