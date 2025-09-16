# Basys3 Multi‑Mode Watch/Stopwatch + UART

**Vivado · Verilog · Basys3 (Artix‑7, xc7a35t‑1cpg236‑1)**  
Digital **Watch/Stopwatch** with debounced inputs, 7‑segment display, and **UART remote control**.  
(※ 본 프로젝트는 카메라/SCCB 기능을 포함하지 않습니다.)

---

## ✨ Features
- **Stopwatch**: Run/Stop 토글, Clear, **0.01 s** 해상도 (msec·sec / min·hour 뷰 전환)
- **Watch**: Up/Down 시간 조정, **단위 커서 이동**(버튼·UART)
- **Display**: 4‑digit 7‑seg, 약 **1 kHz** 스캔, **0.5 s** dot blink
- **Inputs**: 버튼 **디바운스 + 라이징엣지** 검출
- **UART Control**: PC 터미널에서 모드/단위/Up·Down 등 원격 제어

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
 └─ rtl_watch_uart_top.png
```

---

## 🧩 Top Modules
- **top_uart_watch_stopwatch** — Watch/Stopwatch + UART 통합 탑  
  I/O: `clk, rst, sw[1:0], btnU/D/L/R, rx, tx, fnd_data[7:0], fnd_com[3:0], led[3:0], led_pos[2:0]`
- **top_watch** — Watch 전용 탑  
  I/O: `clk, rst, btnL/R/U/D, time_unit, watch_mode, state_led[2:0], fnd_data[7:0], fnd_com[3:0], led[3:0], led_pos[2:0]`

### Internal Blocks (일부)
- `stopwatch_cu.v` / `stopwatch_dp.v` — 3상태 FSM + 100 Hz 틱, **msec→sec→min→hour** 연쇄 카운터
- `watch_cu.v` / `watch_dp.v` — Up/Down/커서 이동 제어 + BCD 타임 카운터
- `fnd_controller.v` — 7‑seg 멀티플렉싱(≈1 kHz), BCD 변환, dot blink
- `btn_debounce.v` — 쉬프트 필터 + 라이징엣지 펄스
- `demux.v` — 모드별 버튼 라우팅(Stopwatch/Watch)
- `led_mode.v` — `sw[1:0]` 상태를 LED로 시각화
- `sw_selector.v`, `switch_controller.v` — 물리 스위치와 **UART 토글** 병합(물리 우선)
- `uart_rx.v`, `uart_tx.v`, `baudrate.v`, `uart_controller.v`, `uart_cu.v` — UART 스택

---

## 🧭 System Block Diagram — Watch/Stopwatch + UART
![UART + Watch Top RTL](docs/rtl_watch_uart_top.png)

**구성 설명**
- **U_UART (uart_controller)**: UART RX/TX 및 보오율 분주. 수신 바이트(`rx_data[7:0]`)와 완료 펄스(`rx_done`) 제공.
- **U_CU (uart_cu)**: 수신 문자를 해석해 **가상 버튼 펄스** `btn_uart[3:0]` 생성 (Up/Down/Run/Clear).
- **OR 결합(RTL_OR)**: 물리 버튼(btnU/D/L/R)과 **UART 버튼**을 OR 결합해 단일 펄스(…_all_i) 생성.
- **U_SW_SEL (sw_selector)**: 물리 스위치 `sw[1:0]`와 UART 토글을 병합해 최종 `sw_final[1:0]` 생성(물리 우선).
- **U_TOP_WATCH (top_watch)**: 최종 버튼/스위치 신호로 Watch/Stopwatch 로직 구동.  
  출력: `fnd_com[3:0]`, `fnd_data[7:0]`, `led[3:0]`, `led_pos[2:0]`.

**신호 대응**
- `sw_final[0]` → **time_unit** (msec·sec ↔ min·hour)  
- `sw_final[1]` → **watch_mode** (Stopwatch ↔ Watch)

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
- 보오율: `baudrate.v` 파라미터 (예: **115200 8N1**)
- 단일 문자 명령(예시): `m`=모드 토글, `u`=업, `d`=다운, `c`=커서 이동, `v`=뷰 단위 토글  
  > 실제 매핑은 `uart_controller.v`/`uart_cu.v` 구현에 맞춰 README에 확정하세요.

---

## 🔧 Build (Vivado)
1. Board: **Basys3 (xc7a35t‑1cpg236‑1)** 프로젝트 생성  
2. Sources 추가: 위 Verilog 파일 추가  
3. Constraints: Basys3 XDC + `create_clock -period 10.0 [get_ports clk]`  
4. Top 선택: `top_uart_watch_stopwatch` 또는 `top_watch`  
5. **Run Synthesis → Implementation → Generate Bitstream → Program Device**

---

## 🧪 Quick Test
- **Stopwatch**: `btnR` 토글, `btnL` 초기화, dot 0.5 s 점멸 확인  
- **Watch**: `sw[1]=1`에서 Up/Down 조정, 단위 커서 이동 확인  
- **UART**: 터미널 연결 → 단문 명령 전송 → 모드/단위/Up·Down 반응 확인

---

## 📋 TODO
- [ ] UART 명령 테이블 README에 확정/기재  
- [ ] 최종 Basys3 **XDC 핀맵** 공개  
- [ ] (옵션) SR04, DHT11 모듈 통합 및 7‑seg 표시 포맷 정의

---

## 📜 License
MIT (또는 선호 라이선스)
