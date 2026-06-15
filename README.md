# SPI-4-MODE

SPI Master Controller hỗ trợ đầy đủ 4 chế độ hoạt động (Mode 0–3), được thiết kế bằng Verilog.

---

## Tổng quan

Module `spi_master` triển khai giao thức SPI ở phía Master, truyền dữ liệu 8-bit nối tiếp (MSB first) qua đường MOSI. Hỗ trợ cả 4 mode SPI thông qua tham số `mode[1:0]` tương ứng với `{CPOL, CPHA}`.

---

## Cổng tín hiệu (Port List)

| Port | Direction | Width | Mô tả |
|------|-----------|-------|--------|
| `clk` | Input | 1-bit | Xung clock hệ thống |
| `rst` | Input | 1-bit | Reset đồng bộ (active HIGH) |
| `start` | Input | 1-bit | Kích hoạt truyền 1 byte |
| `mode` | Input | 2-bit | Chọn SPI mode: `{CPOL, CPHA}` |
| `data_in` | Input | 8-bit | Dữ liệu cần truyền |
| `mosi` | Output | 1-bit | Master Out Slave In |
| `sclk` | Output | 1-bit | SPI Clock |
| `cs` | Output | 1-bit | Chip Select (active LOW) |
| `done` | Output | 1-bit | Pulse báo hoàn thành truyền |

---

## Các SPI Mode được hỗ trợ

| Mode | CPOL | CPHA | Clock idle | Sample edge |
|------|------|------|------------|-------------|
| 0 | 0 | 0 | LOW | Rising |
| 1 | 0 | 1 | LOW | Falling |
| 2 | 1 | 0 | HIGH | Falling |
| 3 | 1 | 1 | HIGH | Rising |

---

## Nguyên lý hoạt động

- Clock nội bộ được chia tần với hệ số **10** (toggle mỗi 5 chu kỳ `clk`), tạo ra `sclk`.
- Khi `start` được kích hoạt, `cs` kéo xuống LOW và bắt đầu shift 8 bit từ MSB.
- **CPHA = 0**: Bit đầu tiên được đưa ra MOSI ngay khi `cs` xuống; các bit tiếp theo cập nhật tại trailing edge.
- **CPHA = 1**: Dữ liệu được cập nhật tại leading edge của `sclk`.
- Sau khi truyền xong 8 bit, `cs` trả về HIGH và `done` pulse 1 chu kỳ.

---

## Testbench

File `testbench.v` kiểm tra lần lượt cả 4 mode với các byte dữ liệu khác nhau:

| Test case | Mode | Data |
|-----------|------|------|
| Mode 0 | `2'b00` | `0xA5` |
| Mode 1 | `2'b01` | `0x3C` |
| Mode 2 | `2'b10` | `0x69` |
| Mode 3 | `2'b11` | `0xF0` |

Waveform được dump ra file `design.vcd` để quan sát bằng GTKWave.

---


## Cấu trúc file

```
SPI-4-MODE/
├── design.v        # RTL: SPI Master module
├── testbench.v     # Testbench kiểm tra 4 mode
└── design.vcd      # Waveform output (sau khi chạy sim)
```

---

## Tác giả

**Skinny Phạm** 
