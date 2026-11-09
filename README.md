<div align="center">

<a id="lasm"></a>

<pre align="center">
 _        _    ____  __  __
| |      / \  / ___||  \/  |
| |     / _ \ \___ \| |\/| |
| |___ / ___ \ ___) | |  | |
|_____/_/   \_\____/|_|  |_|
</pre>
<p><strong>🥔 V<span style="color:#f59e0b">L</span>IW <span style="color:#f59e0b">A</span>SSEMBLY <span style="color:#f59e0b">S</span>CHEDULING <span style="color:#f59e0b">M</span>ACHINE</strong></p>

<p>
  <a href="https://doi.org/10.1145/3810954"><img alt="Paper" src="https://img.shields.io/badge/Paper-ACM%20TODAES-0085CA?logo=acm&amp;logoColor=white"></a>
  <a href="#news"><img alt="LASM" src="https://img.shields.io/badge/LASM-4.0-F59E0B"></a>
  <a href="docs/LAN-spec-v2.0.md"><img alt="LAN" src="https://img.shields.io/badge/LAN-2.0-7B61FF"></a>
  <a href="#quick-start"><img alt="Platform" src="https://img.shields.io/badge/Platform-Linux%20x86__64-111111?logo=linux&amp;logoColor=white"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/License-MIT-2EA44F"></a>
</p>

<p>
  <a href="#quick-start">Quick Start</a> ·
  <a href="#news">News</a> ·
  <a href="#structure">Structure</a> ·
  <a href="docs/LAN-spec-v2.0.md">LAN Specification</a> ·
  <a href="potato/README.md">Potato Guide</a> ·
  <a href="#citation">Citation</a>
</p>

</div>

<a id="news"></a>

> Complexity does not disappear, but it can be shifted. LASM uses LAN, a symbolic assembly interface, to separate VLIW-specific scheduling from the rest of compilation. This lets VLIW designers and mainstream general-purpose compiler toolchains each play to their strengths.

LASM is an extensible scheduling framework for complete VLIW programs expressed in symbolic assembly. Its input language, **VLIW Assembly Notation (LAN)**, uses target ISA instructions with symbolic operands. Physical register bindings, functional unit assignments, and instruction bundling can be specified where needed and left to LASM elsewhere. LASM produces scheduled VLIW assembly with explicit cycle assignments and fully resolved resource bindings.

To support different VLIW architectures, LASM defines an internal abstraction of the VLIW architecture. This abstraction models the architecture in separate layers. All scheduling targets this abstract architecture rather than any concrete processor. For each target, the abstraction is configured with its register files, functional units, instruction set, and additional bundling constraints.

Multiple strategies compete to schedule the same code region. LASM ranks their candidates by scheduling quality and register demand, then selects the highest-ranked feasible schedule. Its internal representation, the **Stratified Assembly Structure (SAS)**, allows scheduled and unscheduled code to coexist within a common scheduling space. Developers can add new strategies through well-defined strategy interfaces and three scheduling primitives. LASM includes three widely used strategies: Top-Down List Scheduling (TDLS), Iterative Modulo Scheduling (IMS), and Swing Modulo Scheduling (SMS). It also includes two strategies that we propose: **Longevity-Aware Expanded Modulo Scheduling (LAEMS)** for software pipelining and **Front-Back Block Fusion (FBBF)** for scheduling across basic-block boundaries.

## 🔥 News

**2026-11** — **LASM 4.0 released.** Evaluated on the paper’s 13 benchmark programs at the same input scales, it improves on the results reported in the paper.

| Performance relative to expert assembly | TODAES'26 | LASM 4.0 |
|---|---:|---:|
| 32-bit VLIW-SIMD DSP (geometric mean) | 103.6% | **105.5%** |
| 64-bit VLIW-SIMD DSP (geometric mean) | 101.6% | **105.8%** |
| Programs at or above expert level | 15 / 26 | **21 / 26** |

## Quick Start

The repository includes a prebuilt LASM 4.0 executable for the Potato target on Linux x86-64. No compilation is required.

```bash
git clone https://github.com/urays/lasm.git
cd lasm
chmod +x potato/tools/lasm

./potato/tools/lasm potato/lan4test/gemm_scalar.lan \
  --layout potato/tools/potato.json \
  --dce --licm \
  --fbbf --tdls \
  --sms --ims \
  --laems --ec=0-8 \
  --output /tmp/lasm-gemm_scalar.s
```

The command enables FBBF and TDLS for linear regions. LASM evaluates the applicable schedules and writes the selected Potato assembly to `/tmp/lasm-gemm_scalar.s`.

```bash
sed -n '1,40p' /tmp/lasm-gemm_scalar.s
./potato/tools/lasm --help
```

## Potato

[Potato](potato/README.md) is a fictional VLIW-SIMD reference architecture that illustrates target integration and code generation in LASM. The bundled executable is configured for Potato; [`potato.json`](potato/tools/potato.json) supplies its memory map and value-passing convention through `--layout`.

## Structure

```text
.
├── docs/
│   └── LAN-spec-v2.0.md           # LAN syntax and semantics
├── potato/
│   ├── README.md                  # Potato reference guide
│   ├── lan4test/                  # Example LAN programs
│   └── tools/
│       ├── lasm                   # Prebuilt Potato executable for Linux x86-64
│       └── potato.json            # Memory map and value-passing convention
├── LICENSE
└── README.md
```

## Citation

If you use LASM in your research, please cite the accompanying article:

```bibtex
@article{zhong2026lasm,
  author    = {Hongli Zhong and Zhong Liu and Sheng Ma},
  title     = {{LASM}: Extensible Competitive Scheduling Framework for {VLIW} Assembly Optimization},
  journal   = {ACM Trans. Des. Autom. Electron. Syst.},
  year      = {2026},
  address   = {New York, NY, USA},
  issn      = {1084-4309},
  publisher = {Association for Computing Machinery},
  doi       = {10.1145/3810954},
  url       = {https://doi.org/10.1145/3810954}
}
```

## License

The contents of this repository are distributed under the [MIT License](LICENSE). Questions and feedback are welcome via [GitHub Issues](https://github.com/urays/lasm/issues).
