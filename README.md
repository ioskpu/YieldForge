# YieldForge

YieldForge is a modular, production-grade DeFi protocol for automated yield optimization on EVM-compatible chains. It routes capital across multiple yield sources, manages risk through on-chain modules, and exposes a composable interface for integrators.

> Status: early development — architecture and contracts are a work in progress.

## Stack

- **Solidity 0.8.24** — core smart contracts
- **Foundry** — build, test, deploy toolchain
- **OpenZeppelin** — battle-tested base contracts
- **EVM target**: Cancun (`via_ir`, optimizer 200 runs)

## Project Structure

```
contracts/
├── core/         # Vault logic, router, accounting
├── interfaces/   # External-facing ABIs
├── libraries/    # Shared math and helpers
└── modules/      # Pluggable yield strategies
script/           # Forge deployment scripts
test/             # Unit, fuzz and invariant tests
lib/              # Dependencies (forge-std, openzeppelin)
```

## Getting Started

```shell
# Install dependencies
forge install

# Build
forge build

# Run tests (with gas report)
forge test --gas-report

# Run fuzz + invariant suite
forge test --match-path "test/**"

# Lint / format
forge fmt
```

## Profiles

| Profile | Fuzz runs | Invariant runs | Use case |
|---------|-----------|----------------|----------|
| `default` | 10 000 | 512 | Local development |
| `ci` | 256 | 64 | CI pipelines |

```shell
# Run with CI profile
FOUNDRY_PROFILE=ci forge test
```

## License

MIT
