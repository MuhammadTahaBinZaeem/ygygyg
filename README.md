# Custom CPU Assembly Language Specification

This document defines a user-facing, MIPS-like assembly language for the custom 20-bit CPU described in the provided README. It is intended to hide opcode/bitfield details while still mapping cleanly to the hardware. Any items marked **Assumption** are inferred from the README text and sample encodings. If the original HDL differs, the assembler/emulator should follow the HDL, not this spec.

## Register Set and Names

* **General-purpose registers:** `r0`–`r7` (3-bit index).
* **Width:** 64-bit registers organized as **4×16-bit lanes**.
  * **Lane 0** = least-significant 16 bits, Lane 3 = most-significant 16 bits. **Assumption** based on typical lane ordering and sample comments.
* **Scalar operations** use the low 16-bit lane and zero upper lanes in results. **Assumption** based on the README’s observation section.
* **Special registers:** `HI` and `LO` (for multiply), and a **status register** containing Z/N/C/V flags.
* `r0` is **not specified as hard-wired zero** in the README; treat it as a normal register. **Assumption**.

## Memory Model

### Instruction memory
* **Harvard architecture:** separate instruction and data memory.
* **Instruction width:** 20 bits.
* **PC width:** 9 bits (0–511), addressing **instruction indices**. **Assumption** from the README; if an implementation truncates to 8 bits, the top bit is ignored.
* **PC increment:** +1 per instruction.
* **Branching:** uses the imm9 field as a signed offset relative to the next instruction. **Assumption** (typical single-cycle design).
* **Jump:** uses the imm9 field as an absolute instruction index (0–511). If only 8 bits are implemented, the top bit is ignored. **Assumption**.

### Data memory
* **Word size:** 16 bits.
* **Addressing:** word-addressed. **Assumption** based on 16-bit data width.
* **Address calculation:** `address = rs + sign_extend(imm9)`.
* **Load (LW):** reads 16-bit data and inserts it into the selected lane; other lanes are zeroed (as described in the README).
* **Store (SW):** writes the selected 16-bit lane to memory.
* **Lane select:** `lane_select[1:0]` chooses lane 0–3.

## Instruction Format (20 bits)

```
[4:0]   opcode
[7:5]   rd
[10:8]  rs
[13:11] rt
[19:14] shamt
[19:11] immediate (imm9) / jump target
[19:18] lane_select (LW/SW)
[17:11] immediate (imm7) for MIN/MAX/EQ (opcodes 29–31)
```

The diagram above shows shared bit positions. Individual instructions reinterpret the same bits as `shamt`, `imm9`, `lane_select`, or `mode_bits` depending on opcode.

**Format by instruction type**

* **R-type:** `opcode + rd + rs + rt` (and `shamt` for shifts).
* **I-type:** `opcode + rd + rs + imm9`.
* **J-type:** `opcode + imm9`.
* **LW/SW (I-modified):** `opcode + rd/rt + rs + imm9 + lane_select[19:18]`.
* **MIN/MAX/EQ (opcodes 29–31):** `opcode + rd + rs + rt/imm7 + mode_bits[19:18]`.

## Assembly Syntax Rules

* **Registers:** `r0`–`r7`
* **Labels:** `label:` on its own line, referenced by name in branches/jumps.
* **Immediates:** decimal (`42`, `-1`) or hex (`0x2A`, `-0x1`).
  * **imm9:** signed 9-bit two’s-complement for most I-type instructions (range -2^8 to 2^8-1; values outside this range are invalid).
  * **imm7:** signed 7-bit two’s-complement for MIN/MAX/EQ immediate variants (range -2^6 to 2^6-1).
  * **shamt:** 6-bit unsigned (range 0..63).
* **Comments:** `// comment`
* **Lane selection:** optional `.L0`/`.L1`/`.L2`/`.L3` suffix for LW/SW (default `.L0`).

## Instruction Reference

### Scalar R-type ALU

| Mnemonic | Example syntax | Description | Fields used |
| --- | --- | --- | --- |
| ADD | `ADD rd, rs, rt` | Scalar add. Updates flags, writes rd. | `opcode=0, rd, rs, rt` |
| SUB | `SUB rd, rs, rt` | Scalar subtract. Updates flags, writes rd. | `opcode=1, rd, rs, rt` |
| AND | `AND rd, rs, rt` | Scalar bitwise AND. Updates flags. | `opcode=2, rd, rs, rt` |
| OR | `OR rd, rs, rt` | Scalar bitwise OR. Updates flags. | `opcode=3, rd, rs, rt` |
| XOR | `XOR rd, rs, rt` | Scalar bitwise XOR. Updates flags. | `opcode=4, rd, rs, rt` |
| SLL | `SLL rd, rs, shamt` | Shift left logical. Updates flags. | `opcode=5, rd, rs, shamt[19:14]` |
| SRL | `SRL rd, rs, shamt` | Shift right logical. Updates flags. | `opcode=6, rd, rs, shamt[19:14]` |
| MUL | `MUL rs, rt` | Scalar multiply. Writes HI/LO, updates flags. | `opcode=7, rs, rt` (rd unused) |

### Vector ALU (4×16-bit lanes)

| Mnemonic | Example syntax | Description | Fields used |
| --- | --- | --- | --- |
| VADD | `VADD rd, rs, rt` | Lane-wise add. | `opcode=8, rd, rs, rt` |
| VMUL | `VMUL rd, rs, rt` | Lane-wise multiply. | `opcode=9, rd, rs, rt` |
| VMIN | `VMIN rd, rs, rt` | Lane-wise signed minimum. | `opcode=21, rd, rs, rt` |
| VMAX | `VMAX rd, rs, rt` | Lane-wise signed maximum. | `opcode=22, rd, rs, rt` |
| VABS | `VABS rd, rs` | Lane-wise absolute value (signed). | `opcode=23, rd, rs` (rt unused) |
| VEQ | `VEQ rd, rs, rt` | Lane-wise compare equal (0xFFFF or 0x0000). | `opcode=24, rd, rs, rt` |
| VSEL | `VSEL rd, rs, rt` | If lane in rt ≠ 0, take rs lane else 0. | `opcode=25, rd, rs, rt` |
| VPASSA | `VPASSA rd, rs` | Pass-through rs lanes. | `opcode=26, rd, rs` (rt unused) |
| VZERO | `VZERO rd` | Zero all lanes. | `opcode=27, rd` |
| VREV | `VREV rd, rs` | Reverse lane order. | `opcode=28, rd, rs` |

### Immediate (I-type)

| Mnemonic | Example syntax | Description | Fields used |
| --- | --- | --- | --- |
| ADDI | `ADDI rd, rs, imm` | Scalar add immediate. Updates flags. | `opcode=10, rd, rs, imm9[19:11]` |
| VADDI | `VADDI rd, rs, imm` | Vector add immediate (replicated). | `opcode=11, rd, rs, imm9[19:11]` |
| LW | `LW.L0 rd, offset(rs)` | Load 16-bit word into selected lane. | `opcode=12, rd, rs, imm9[19:11], lane_select[19:18]` |
| SW | `SW.L0 rt, offset(rs)` | Store selected lane from rt. | `opcode=13, rs, rt, imm9[19:11], lane_select[19:18]` |
| LI | `LI rd, imm` | Load immediate into low 16 bits. | `opcode=14, rd, imm9[19:11]` |
| VLI | `VLI rd, imm` | Load immediate, replicated to all lanes. | `opcode=15, rd, imm9[19:11]` |

> **Assumption (SW encoding):** The field layout shows `rt` in bits [13:11] while `imm9` spans [19:11], so the low 3 bits overlap. If the implementation treats these bits independently, the assembler can ignore the overlap; otherwise it must enforce that the offset’s low 3 bits match `rt`.

### Branch/Jump

| Mnemonic | Example syntax | Description | Fields used |
| --- | --- | --- | --- |
| BEQZ | `BEQZ rs, offset` | Branch if rs == 0. | `opcode=16, rs, imm9[19:11]` |
| BEQ | `BEQ rs, rt, offset` | Branch if rs == rt. | `opcode=17, rs, rt, imm9[19:11]` |
| J | `J target` | Jump to absolute target index. | `opcode=18, imm9[19:11]` |

### Special-register moves

| Mnemonic | Example syntax | Description | Fields used |
| --- | --- | --- | --- |
| MFHI | `MFHI rd` | Move HI into rd. | `opcode=19, rd` |
| MFLO | `MFLO rd` | Move LO into rd. | `opcode=20, rd` |

### Extended MIN/MAX/EQ (opcodes 29–31)

These opcodes reuse bits `[19:18]` as **mode bits** (not lane selection):

* `mode_bits[0] = 1` → immediate variant (uses imm7 in bits [17:11])
* `mode_bits[1] = 1` → vector-lane operation (4×16-bit lanes)

| Mnemonic | Example syntax | Description | Fields used |
| --- | --- | --- | --- |
| MIN | `MIN rd, rs, rt` | Scalar min. | `opcode=29, rd, rs, rt, mode_bits=00` |
| MINI | `MINI rd, rs, imm` | Scalar min immediate. | `opcode=29, rd, rs, imm7[17:11], mode_bits=01` |
| MIN.V | `MIN.V rd, rs, rt` | Vector min. | `opcode=29, rd, rs, rt, mode_bits=10` |
| MIN.VI | `MIN.VI rd, rs, imm` | Vector min immediate. | `opcode=29, rd, rs, imm7[17:11], mode_bits=11` |
| MAX | `MAX rd, rs, rt` | Scalar max. | `opcode=30, rd, rs, rt, mode_bits=00` |
| MAXI | `MAXI rd, rs, imm` | Scalar max immediate. | `opcode=30, rd, rs, imm7[17:11], mode_bits=01` |
| MAX.V | `MAX.V rd, rs, rt` | Vector max. | `opcode=30, rd, rs, rt, mode_bits=10` |
| MAX.VI | `MAX.VI rd, rs, imm` | Vector max immediate. | `opcode=30, rd, rs, imm7[17:11], mode_bits=11` |
| EQ | `EQ rd, rs, rt` | Scalar compare equal. | `opcode=31, rd, rs, rt, mode_bits=00` |
| EQI | `EQI rd, rs, imm` | Scalar compare equal immediate. | `opcode=31, rd, rs, imm7[17:11], mode_bits=01` |
| EQ.V | `EQ.V rd, rs, rt` | Vector compare equal. | `opcode=31, rd, rs, rt, mode_bits=10` |
| EQ.VI | `EQ.VI rd, rs, imm` | Vector compare equal immediate. | `opcode=31, rd, rs, imm7[17:11], mode_bits=11` |

> **Assumption (EQ semantics):** Scalar EQ writes 1 (true) or 0 (false) in the low 16 bits. Vector EQ uses 0xFFFF/0x0000 per lane, consistent with the README’s VEQ description.
