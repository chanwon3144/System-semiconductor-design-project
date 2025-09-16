# Basys3 Multi‑Mode Watch/Stopwatch + UART (+ Camera Pipeline Ready)

**Vivado · Verilog · Basys3 (Artix‑7, xc7a35t‑1cpg236‑1)**  
Digital **Watch/Stopwatch** with debounced inputs, 7‑segment display, and **UART remote control**.  
Optional **OV7670 → FrameBuffer → VGA** camera pipeline (SCCB, grayscale, GUI overlay) included as a separate block diagram.

---

## ✨ Features
- **Stopwatch**: Run/Stop toggle, Clear, **0.01 s** resolution (msec·sec / min·hour 뷰 전환)
- **Watch**: Up/Down 시간 조정, 단위 커서 이동(버튼·UART)
- **Display**: 4‑digit 7‑seg, 약 **1 kHz** 스캔, 0.5 s 도트 블링크
- **Inputs**: 버튼 **디바운스 + 라이징엣지** 검출
- **UART Control**: PC 터미널에서 모드/단위/업·다운 등 제어 (명령 표는 아래)
- **(옵션) Camera**: OV7670 캡처 → BRAM → VGA 640×480, **그레이/GUI** MUX, **SCCB(I²C)**

---

## 📦 Repository
```
- baudrate.v
- btn_debounce.v
- demux.v
- fnd_controller.v
- led_mode.v
- mux_watch_swatch.v
- stopwatch.v
- stopwatch_cu.v
- stopwatch_dp.v
- sw_selector.v
- switch_controller.v
- top_uart_watch_stopwatch.v
- top_watch.v
- uart_controller.v
- uart_cu.v
- uart_rx.v
- uart_tx.v
- watch.v
- watch_cu.v
- watch_dp.v
docs/
 └─ rtl_camera_vga.png
```
> 센서(SR04/DHT11) RTL은 별도 추가 예정입니다.

---

## 🧩 Top Modules
- **top_uart_watch_stopwatch** — Watch/Stopwatch + UART 통합 탑  
  I/O: `clk, rst, sw[1:0], btnU/D/L/R, rx, tx, fnd_data[7:0], fnd_com[3:0], led[3:0], led_pos[2:0]`
- **top_watch** — Watch 전용 탑  
  I/O: `clk, rst, btnL/R/U/D, time_unit, watch_mode, state_led[2:0], fnd_data[7:0], fnd_com[3:0], led[3:0], led_pos[2:0]`

### Internal Blocks (일부)
- `stopwatch_cu.v` / `stopwatch_dp.v` — 3상태 FSM + 100 Hz 틱, **msec→sec→min→hour** 연쇄 카운터
- `watch_cu.v` / `watch_dp.v` — 업/다운/커서 이동 제어 + BCD 타임 카운터
- `fnd_controller.v` — 7‑seg 멀티플렉싱(≈1 kHz), BCD 변환, 도트 블링크
- `btn_debounce.v` — 쉬프트 필터 + 라이징엣지 펄스
- `demux.v` — 모드별 버튼 라우팅(Stopwatch/Watch)
- `led_mode.v` — `sw[1:0]` 시각화
- `sw_selector.v`, `switch_controller.v` — 물리 스위치와 **UART 토글** 병합
- `uart_rx.v`, `uart_tx.v`, `baudrate.v`, `uart_controller.v`, `uart_cu.v` — UART 스택

---

## 🕹 Controls
| 입력 | 의미 | 비고 |
|---|---|---|
| `sw[1]` | 모드 | 0=Stopwatch / 1=Watch |
| `sw[0]` | 뷰 단위 | 0=msec·sec / 1=min·hour |
| `btnR` | 실행/정지(Stopwatch) | |
| `btnL` | 초기화(Stopwatch) | |
| `btnU` | 업(Watch) | |
| `btnD` | 다운(Watch) | |

### UART
- 보오율: `baudrate.v`의 파라미터에 따름 (예: 115200 8N1 등)
- 단일 문자 명령 예시(권장):  
  `m`=모드 토글, `u`=업, `d`=다운, `c`=커서 이동, `v`=뷰 단위 토글 …  
  > 실제 매핑은 `uart_controller.v`/`uart_cu.v` 구현에 맞춰 README에 확정하세요.

---

## 🖥 7‑Segment Display
- 4‑digit 스캔 ≈ **1 kHz**  
- **Stopwatch**: msec(00–99)·sec(00–59) 또는 min(00–59)·hour(00–23) 뷰  
- **Watch**: 선택된 단위 커서 이동 후 Up/Down 조정  
- **Dot**: 0.5 s 주기로 점멸(초 가독성)

---

## 📷 (Optional) Camera Pipeline
![RTL Block Diagram](docs/rtl_camera_vga.png)

- OV7670 `PCLK/HREF/VSYNC/D[7:0]` 캡처 → RGB565 → **BRAM(dual‑port)**  
- BRAM write: `ov7670_pclk` / read: 시스템 `clk` → **VGA 640×480**  
- `GrayScaleFilter` / `GUI` 오버레이 / **3×1 MUX** (raw/gray/gui)  
- **SCCB(I²C)**: 카메라 레지스터 초기화, `xclk` 출력  
- **CDC**: `VSYNC` 2‑FF 동기화, frame_start/end 게이팅

---

## 🔧 Build (Vivado)
1. Board: **Basys3 (xc7a35t‑1cpg236‑1)** 프로젝트 생성  
2. Sources 추가: 위 Verilog 파일 추가(필요 시 `camera/` 블록 별도)  
3. Constraints: Basys3 XDC 추가, `create_clock -period 10.0 [get_ports clk]`  
4. Top 선택: `top_uart_watch_stopwatch` 또는 `top_watch`  
5. **Run Synthesis → Implementation → Generate Bitstream → Program Device**

---

## 🧪 Quick Test
- **Stopwatch**: `btnR` 토글, `btnL` 초기화, 도트 0.5 s 점멸 확인  
- **Watch**: `sw[1]=1`에서 Up/Down 조정, 단위 커서 이동 확인  
- **UART**: 터미널 연결 후 명령 전송 → 모드/단위/업·다운 반응 확인  
- **Camera(옵션)**: SCCB ACK, `wAddr` 진행, VGA 싱크 안정성, raw/gray/gui 전환

---

## 📋 TODO
- [ ] SR04, DHT11 모듈 통합 및 7‑seg 표시 포맷 정의(cm/℃·%RH)  
- [ ] UART 명령 테이블 확정 및 README 반영  
- [ ] 최종 Basys3 **XDC 핀맵** 공개

---

## 📜 License
MIT (또는 선호하는 라이선스를 `LICENSE` 파일로 추가)
