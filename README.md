<div align="center">
  <p>
    <code>&nbsp;&nbsp;&nbsp;__&nbsp;&nbsp;&nbsp;&nbsp;_____&nbsp;_____&nbsp;_____</code><br>
    <code>&nbsp;&nbsp;|&nbsp;&nbsp;|&nbsp;&nbsp;|&nbsp;&nbsp;_&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;__|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|</code><br>
    <code>&nbsp;&nbsp;|&nbsp;&nbsp;|__|&nbsp;|_|&nbsp;|__&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;|&nbsp;&nbsp;|</code><br>
    <code>&nbsp;&nbsp;|_____|&nbsp;___&nbsp;|_____|_&nbsp;|&nbsp;_|</code>
  </p>
  <p><strong>🐌 VLIW ASSEMBLY SCHEDULING MACHINE.</strong></p>
  <p>LASM compiles LAN symbolic assembly into scheduled VLIW assembly. This public artifact provides the LAN specification, a runnable Linux x86_64 binary, and a Potato VLIW target for trying the scheduling workflow.</p>

  <p>
    <img alt="Artifact" src="https://img.shields.io/badge/Artifact-Public-2ea44f">
    <img alt="Platform" src="https://img.shields.io/badge/Platform-Linux%20x86__64-111111?logo=linux&logoColor=white">
    <img alt="Target" src="https://img.shields.io/badge/Target-Potato%20VLIW-f59e0b">
    <img alt="License" src="https://img.shields.io/badge/License-MIT-blue">
  </p>

  <p>
    <a href="#quick-start">Quick Start</a> ·
    <a href="#artifact-contents">Artifact Contents</a> ·
    <a href="#scope">Scope</a> ·
    <a href="#public-target">Public Target</a> ·
    <a href="#license">License</a>
  </p>
</div>

---

## Quick Start

The Potato example includes a pre-built LASM binary for Linux x86_64:

```bash
cd example-potato
chmod +x tools/lasm
./tools/lasm lan4test/gemm_scalar.lan \
  --layout tools/potato.json \
  --dce --licm \
  --laems --ec=0-8 --ims --fbbfc --fbbfl --tdlsc --tdlsl \
  --output gemm_scalar.s
```

Useful commands:

| What you want | Command |
| --- | --- |
| Show compiler options | `cd example-potato && ./tools/lasm --help` |
| Compile scalar GEMM | `cd example-potato && ./tools/lasm lan4test/gemm_scalar.lan --layout tools/potato.json --output gemm_scalar.s` |
| Compile vector GEMM with fused multiply-add | `cd example-potato && ./tools/lasm lan4test/sgemm_vector_muladd.lan --layout tools/potato.json --output sgemm_muladd.s` |
| Read the Potato guide | `example-potato/README.md` |
| Read the LAN specification | `docs/LAN-spec-v2.0.md` |

## Artifact Contents

| Component | Status | Notes |
| --- | ---: | --- |
| LAN language specification | Available | `docs/LAN-spec-v2.0.md` |
| Potato VLIW reference target | Available | Fictional public target under `example-potato/` |
| Runnable LASM compiler | Available | Linux x86_64 binary under `example-potato/tools/lasm` |
| Example LAN programs | Available | GEMM examples under `example-potato/lan4test/` |
| Full LASM source tree | Pending | Awaiting institutional review and removal of confidentiality-restricted components |
| LLVM-based public source release | In preparation | Source release information will be announced in this repository after review |
| Production processor descriptions | Not included | Restricted by confidentiality and third-party constraints |

## Scope

This artifact is intended for inspecting LAN, running the public Potato example,
and exercising LASM's scheduling workflow on a non-confidential target. It is
not the complete production LASM source release.

Production target descriptions, proprietary processor details, benchmark
materials covered by third-party restrictions, and components affected by
confidentiality agreements are not included. The complete public source release
will be provided after institutional review and source-tree cleanup are
complete.

## Public Target

Potato is a fictional VLIW vector processor used only as a public reference
target. It demonstrates:

- symbolic LAN programs with automatic register allocation;
- configurable register files, functional units, and instruction constraints;
- multi-strategy scheduling options including LAEMS, FBBF, IMS, and TDLS;
- a complete command-line flow from LAN input to generated assembly.

See `example-potato/README.md` for the target description, instruction examples,
and additional usage guidance.

## Repository Layout

```text
.
├── docs/
│   └── LAN-spec-v2.0.md          # LAN syntax and semantic specification
├── example-potato/
│   ├── README.md                 # Potato target guide and examples
│   ├── lan4test/                 # Public LAN example programs
│   └── tools/
│       ├── lasm                  # Pre-built Linux x86_64 LASM binary
│       └── potato.json           # Potato memory layout and calling convention
├── scripts/                      # Development environment helper scripts
├── third-party/                  # Public third-party headers and libraries
└── LICENSE
```

## License

This artifact is released under the MIT License. See `LICENSE` for details.
