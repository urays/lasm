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
  <a href="docs/article.pdf"><img alt="Paper" src="https://img.shields.io/badge/Paper-ACM%20TODAES-0085CA?logo=acm&amp;logoColor=white"></a>
  <a href="#lasm"><img alt="LASM" src="https://img.shields.io/badge/LASM-3.2.5.2-F59E0B"></a>
  <a href="docs/LAN-spec-v2.0.md"><img alt="LAN" src="https://img.shields.io/badge/LAN-2.0-7B61FF"></a>
  <a href="#quick-start"><img alt="Platform" src="https://img.shields.io/badge/Platform-Linux%20x86__64-111111?logo=linux&amp;logoColor=white"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/License-MIT-2EA44F"></a>
</p>

<p>
  <a href="#quick-start">Quick Start</a> ·
  <a href="#project-structure">Project Structure</a> ·
  <a href="docs/LAN-spec-v2.0.md">LAN Specification</a> ·
  <a href="potato/README.md">Potato Guide</a> ·
  <a href="#citation">Citation</a>
</p>

</div>

> Complexity does not disappear, but it can be shifted. LASM uses LAN, a symbolic assembly interface, to separate VLIW-specific scheduling from the rest of compilation. This lets VLIW designers and mainstream general-purpose compiler toolchains each play to their strengths.

LASM is an extensible scheduling framework for complete VLIW programs expressed in symbolic assembly. Its input language, **VLIW Assembly Notation (LAN)**, uses target ISA instructions with symbolic operands. Physical register bindings, functional unit assignments, and instruction bundling can be specified where needed and left to LASM elsewhere. LASM produces scheduled VLIW assembly with explicit cycle assignments and fully resolved resource bindings.

Multiple strategies compete to schedule the same code region. LASM ranks their candidates by scheduling quality and register demand, then selects the highest-ranked feasible schedule. Its internal representation, the **Stratified Assembly Structure (SAS)**, allows scheduled and unscheduled code to coexist within a function. Standardized extension interfaces and reusable scheduling primitives help developers add new strategies. Alongside implementations of TDLS, IMS, and EMS, LASM introduces **LAEMS** for software pipelining and **FBBF** for scheduling across block boundaries.

In the paper’s evaluation across 13 benchmarks on two production VLIW-SIMD processors, LASM achieves geometric mean performance ratios of **103.6%** and **101.6%** relative to assembly hand-optimized by experts. LAN implementations use **72.6% fewer source lines** in total than the corresponding handwritten assembly implementations, excluding blank lines. An end-to-end YOLOv5 deployment reaches **95.9%** of expert assembly performance while reducing implementation effort from **9 to 3 engineer-weeks**.

## Quick Start

The repository includes a prebuilt LASM executable for the Potato target on Linux x86-64. No compilation is required.

```bash
git clone https://github.com/urays/lasm.git
cd lasm
chmod +x potato/tools/lasm

./potato/tools/lasm potato/lan4test/gemm_scalar.lan \
  --layout potato/tools/potato.json \
  --dce --licm \
  --fbbfl --tdlsl \
  --output /tmp/lasm-gemm_scalar.s
```

The command enables FBBF and TDLS for linear regions. LASM evaluates the applicable schedules and writes the selected Potato assembly to `/tmp/lasm-gemm_scalar.s`.

```bash
sed -n '1,40p' /tmp/lasm-gemm_scalar.s
./potato/tools/lasm --help
```

## Potato

[Potato](potato/README.md) is a fictional VLIW-SIMD reference architecture that illustrates target integration and code generation in LASM. The bundled executable is configured for Potato; [`potato.json`](potato/tools/potato.json) supplies its memory map and value-passing convention through `--layout`.

## Project Structure

```text
.
├── docs/
│   ├── article.pdf                # Full paper
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

## Documentation

- [LAN 2.0 specification](docs/LAN-spec-v2.0.md): formal language syntax and semantics.
- [Potato guide](potato/README.md): reference architecture, instruction set, and compilation workflow.

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
