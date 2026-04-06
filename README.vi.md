# SkillsOver

[![GitHub stars](https://img.shields.io/github/stars/dearvn/skillsover?style=flat-square)](https://github.com/dearvn/skillsover/stargazers)
[![License](https://img.shields.io/github/license/dearvn/skillsover?style=flat-square)](LICENSE)

**Bộ skill AI giúp giảm 87% chi phí token. Tương thích với Claude Code, Cursor, Cline, Copilot.**

[English](README.md) | Tiếng Việt | [中文](README.zh.md)

```bash
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```

```bash
npx skillsadd dearvn/skillsover   # alternative
```

Sau đó chỉ cần gõ `/commit`, `/debug`, `/review` — và thôi trả tiền cho phần mở đầu thừa thãi của Claude.

![SkillsOver demo](demo.gif)

---

## Vấn đề

```
KHÔNG CÓ skill:

  Bạn: "fix the bug in OrderService"
         │
         ├─ Claude đọc 6 file "để nắm context"   +4,800 tokens
         ├─ Claude hỏi thêm 2 câu làm rõ          +  800 tokens
         ├─ Claude giải thích đang làm gì          +  300 tokens
         └─ Claude tóm tắt những gì đã làm         +  200 tokens
                                                   ───────────
                                            Tổng:  ~6,100 tokens  ≈ $0.040


CÓ /debug:

  Bạn: /debug [dán lỗi vào đây]
         │
         ├─ Claude đọc đúng 1 file tại dòng cụ thể  + 800 tokens
         └─ Claude xuất ra: nguyên nhân + bản sửa   + 200 tokens
                                                     ──────────
                                              Tổng:  ~1,000 tokens  ≈ $0.005

                                                          Ít hơn 84%  ↓
```

---

## Các công cụ được hỗ trợ

| Công cụ | Vị trí cài đặt | Cách gọi |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `/commit`, `/debug`... |
| **Cursor** | `.cursor/rules/` | `@commit`, `@debug`... |
| **Cline** | `.clinerules/` | nhắc trong chat |
| **Copilot** | `.github/` | nhắc trong chat |

```bash
# Claude Code (mặc định)
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash

# Cursor
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash --tool cursor

# Cline
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash --tool cline
```

---

## Tiết kiệm token

| Tác vụ | Không có skill | Có skill | Tiết kiệm |
|---|---|---|---|
| Viết commit message | ~$0.0138 | ~$0.0018 | **87%** |
| Debug lỗi | ~$0.0400 | ~$0.0051 | **87%** |
| Mỗi tháng (5 phiên/ngày) | ~$50 | ~$7 | **~$43/tháng** |

Tính mức tiết kiệm của bạn: `bash <(curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/scripts/gain.sh)`

---

## Danh sách skill

```
/commit    Tạo commit theo chuẩn semantic từ staged diff — không hỏi qua hỏi lại
/review    Review trước khi tạo PR: bảo mật P0, logic P1, hiệu năng P2
/debug     Phân tích nguyên nhân gốc rễ 4 bước — không đoán mò
/test      Viết test cho mọi framework (pytest, Jest, Go, RSpec...)
/explain   Giải thích code: làm gì → hoạt động thế nào → điểm cần chú ý — bỏ qua cái hiển nhiên
/security  Kiểm tra OWASP Top 10, chỉ đọc, chỉ báo cáo phát hiện
/perf      Profile trước, tối ưu đúng điểm nghẽn thực sự
/docs      JSDoc / docstrings / godoc — ghi lại TẠI SAO chứ không phải LÀM GÌ
/refactor  Refactor an toàn, viết characterization test trước
/safe-edit Chỉnh sửa mà không phá vỡ hành vi hiện có
```

---

## Tài liệu

- [GETTING_STARTED.md](GETTING_STARTED.md) — bắt đầu từ đầu đến skill đầu tiên trong 5 phút
- [TOKEN_COST.md](TOKEN_COST.md) — số liệu cụ thể về lý do hóa đơn tăng vọt và cách skill khắc phục
- [WHY.md](WHY.md) — so sánh với các lựa chọn khác

---

## Tham khảo từng Skill

### `/commit` — Tạo Commit Semantic từ Diff
**Dùng khi nào**: Sau khi stage thay đổi, thay vì tự viết commit message.

**Cách hoạt động**:
1. Đọc `git diff --staged` và `git status`
2. Xác định loại commit (feat/fix/refactor/perf/test/docs/chore/style)
3. Viết tóm tắt theo lệnh gọi, dưới 72 ký tự
4. Tạo commit đúng định dạng

**Ví dụ kết quả**:
```
feat(auth): add refresh token rotation
fix(api): return 404 instead of 500 for missing resource
perf(cache): cache dashboard stats with 60s TTL
```

**Chi phí token**: ~300 tokens (chỉ đọc staged diff)
**Thời gian tiết kiệm**: 2-5 phút mỗi commit, loại bỏ commit message kém chất lượng

---

### `/review` — Review Code Trước khi Tạo PR
**Dùng khi nào**: Trước khi mở PR, hoặc khi review PR của người khác.

**Cách hoạt động**:
1. Đọc diff giữa nhánh hiện tại và main
2. Kiểm tra các vấn đề bảo mật OWASP (P0 — chặn PR)
3. Kiểm tra lỗi logic và tính đúng đắn (P1 — chặn PR)
4. Kiểm tra vấn đề hiệu năng (P2 — gợi ý)
5. Báo cáo phát hiện với tham chiếu file:dòng — không khen ngợi, không lấp đầy

**Ví dụ kết quả**:
```
[P0] api/users.ts:45 — User input passed directly to SQL query string
Suggestion: Use parameterized query or ORM

[P1] services/order.ts:112 — Missing null check before .items.length
Suggestion: Add guard: if (!order?.items) return []
```

**Chi phí token**: ~800-1500 tokens (đọc diff + các file liên quan)
**Thời gian tiết kiệm**: Phát hiện lỗi trước vòng review (tiết kiệm 1-3 vòng review)

---

### `/debug` — Phân Tích Nguyên Nhân Gốc Rễ
**Dùng khi nào**: Bất cứ khi nào có lỗi, crash, hoặc hành vi không mong muốn.

**Cách hoạt động**:
Quy trình 4 bước — không đoán mò:
1. **REPRODUCE** — lấy chính xác nội dung lỗi, các bước tái hiện
2. **LOCATE** — truy vết stack đến file:dòng cụ thể
3. **HYPOTHESIZE** — đặt ra MỘT giả thuyết, kiểm chứng nó
4. **FIX** — sửa đúng nguyên nhân gốc, không refactor xung quanh

**Ví dụ kết quả**:
```
Root cause: Redis connection not re-established after EAGAIN error
Evidence: market_pressure_service.py:847 — ctx->err not cleared after error
Fix: Add ctx->err = 0 and reconnect logic after EAGAIN returns
Risk: Must test reconnection under load — single-threaded Redis ctx
```

**Chi phí token**: ~500-1000 tokens (chỉ đọc các file trong stack trace)
**Thời gian tiết kiệm**: Loại bỏ các phiên debug 30-60 phút bằng quy trình có hệ thống

---

### `/test` — Viết Test cho Code Có Sẵn
**Dùng khi nào**: Sau khi viết một hàm, hoặc để bổ sung coverage còn thiếu.

**Cách hoạt động**:
1. Đọc hàm/module cần test
2. Xác định: happy path, edge case, error path
3. Mock các dependency bên ngoài (HTTP, DB, time, filesystem)
4. Viết test theo cấu trúc AAA (Arrange/Act/Assert)
5. Mỗi test một assertion

**Hỗ trợ**: pytest, Jest, xUnit, Go testing, RSpec — bất kỳ framework nào

**Chi phí token**: ~600-1200 tokens
**Thời gian tiết kiệm**: Viết test từ đầu cho hàm 50 dòng mất 20-40 phút; với /test chỉ ~5 phút

---

### `/explain` — Giải Thích Code để Hiểu
**Dùng khi nào**: Onboarding vào codebase mới, hoặc hiểu logic phức tạp.

**Cách hoạt động**:
1. Đọc đoạn code được chỉ định
2. Xác định trình độ của bạn từ ngữ cảnh
3. Giải thích: làm gì → hoạt động thế nào → các khái niệm chính → điểm cần chú ý
4. Bỏ qua phần hiển nhiên — chỉ giải thích những gì người đọc thực sự có thể bỏ lỡ

**Ví dụ sử dụng**:
```
/explain this function [select code]
/explain how authentication works in this codebase
/explain the DTE routing logic in market_pressure_service.py
```

**Chi phí token**: ~400-800 tokens
**Phù hợp nhất cho**: Onboarding, hiểu code khi review, debug code không quen thuộc

---

### `/security` — Kiểm Tra Bảo Mật Nhanh
**Dùng khi nào**: Trước khi deploy tính năng mới, hoặc kiểm tra endpoint hiện có.

**Cách hoạt động**:
Kiểm tra OWASP Top 10 — chỉ đọc, không bao giờ chỉnh sửa code:
- SQL injection, XSS, path traversal
- Xác thực bị hỏng (thiếu middleware, JWT validation)
- Secret trong code
- Deserialization không an toàn
- Ghi log dữ liệu nhạy cảm

**Ví dụ kết quả**:
```
[CRITICAL] routes/upload.ts:67 — File extension not validated before save
Fix: Validate MIME type + extension whitelist, never trust Content-Type header

[HIGH] middleware/auth.ts:23 — JWT expiry not checked
Fix: Verify exp claim: if (decoded.exp < Date.now() / 1000) throw Unauthorized()
```

**Chi phí token**: ~600-1000 tokens
**Lý do tiết kiệm tiền**: Phát hiện lỗi bảo mật trước khi deploy so với sau khi bị vi phạm = chênh lệch chi phí hàng chục lần

---

### `/perf` — Phân Tích Hiệu Năng
**Dùng khi nào**: Khi có gì đó chạy chậm mà không rõ nguyên nhân.

**Cách hoạt động**:
1. **Profile trước** — cung cấp lệnh profiling cho stack của bạn trước khi đọc bất kỳ code nào
2. **Xác định điểm nghẽn** — chỉ đọc hàm chậm được xác định bởi profiler
3. **Nhận diện mẫu** — N+1, thiếu index, không phân trang, blocking I/O, re-render
4. **Đề xuất sửa** — thay đổi cụ thể với tác động dự kiến

**Các phát hiện phổ biến**:
- N+1 queries (vòng lặp với DB call) → batch bằng mệnh đề `IN`
- `SELECT *` trên bảng 50 cột → chỉ select cột cần thiết
- Thiếu index trên cột WHERE → thêm index
- React component re-render mỗi lần nhấn phím → memo hoặc debounce

**Chi phí token**: ~500-900 tokens
**Nguyên tắc**: Không bao giờ bỏ qua bước profiling. Tối ưu sai chỗ là lãng phí thời gian của mọi người.

---

### `/docs` — Tạo Tài Liệu Inline
**Dùng khi nào**: Sau khi viết hàm, hoặc trước PR để bổ sung tài liệu còn thiếu.

**Cách hoạt động**:
1. Đọc code cần tài liệu hóa
2. Xác định những gì thực sự cần giải thích (bỏ qua phần hiển nhiên)
3. Tạo JSDoc / Python docstrings / C# XML docs / Go godoc
4. Ghi lại: params, giá trị trả về, throws/errors, side effects, ví dụ

**Nguyên tắc thiết kế**: Ghi lại TẠI SAO, không phải LÀM GÌ. Code đã thể hiện cái gì rồi.

**Hỗ trợ**: TypeScript (JSDoc), Python (Google style), C# (XML), Go (godoc), Java (Javadoc)

**Chi phí token**: ~300-600 tokens
**Thời gian tiết kiệm**: Viết tài liệu tốt cho một hàm phức tạp mất 10-20 phút; /docs làm trong vài giây

---

### `/refactor` — Refactor An Toàn
**Dùng khi nào**: Khi code chạy đúng nhưng khó đọc, khó bảo trì hoặc khó test.

**Cách hoạt động**:
1. Đọc và hiểu hành vi hiện tại (kể cả edge case)
2. Viết characterization test nếu chưa có
3. Áp dụng MỘT kiểu refactor: extract function / đổi tên / loại bỏ trùng lặp / đơn giản hóa điều kiện / tách hàm
4. Chạy test sau mỗi bước

**Nguyên tắc**: Không bao giờ thay đổi logic và cấu trúc trong cùng một commit.

**Chi phí token**: ~700-1500 tokens
**Giảm rủi ro**: Characterization test phát hiện thay đổi hành vi ngoài ý muốn — tiết kiệm thời gian debug regression

---

## Nguyên Tắc Thiết Kế

### Tại sao các skill này tiết kiệm token

| Không có skill | Có skill |
|--------------|------------|
| Claude tự nghĩ ra cách tiếp cận từ đầu mỗi lần | Cách tiếp cận được định sẵn — Claude thực thi trực tiếp |
| Nhiều vòng hỏi làm rõ | Một lần gọi duy nhất với kết quả rõ ràng |
| Claude đọc quá nhiều file "để nắm context" | Skill giới hạn phạm vi đọc ở mức tối thiểu |
| In ra chuỗi suy luận dài | Skill chỉ xuất đúng định dạng kết quả |

### Thiết kế skill hiệu quả về token
1. **Xác định phạm vi** — chỉ rõ cho Claude đọc file nào, và KHÔNG đọc file nào
2. **Xác định định dạng đầu ra** — Claude không suy nghĩ về cách trình bày; nó điền vào template
3. **Xác định quy trình** — các bước đánh số loại bỏ chi phí khám phá
4. **Loại bỏ filler** — "Chỉ xuất phát hiện, không khen ngợi" cắt giảm 40-60% token đầu ra

---

## Đóng Góp

Một skill phổ quát tốt cần:
- Hoạt động với mọi ngôn ngữ/framework (hoặc nêu rõ yêu cầu)
- Đọc số file tối thiểu cần thiết — không bao giờ "đọc để nắm context"
- Có định dạng đầu ra rõ ràng
- Tiết kiệm nhiều thời gian hơn thời gian cần để gọi nó

Thêm skill của bạn dưới dạng `skills/{name}.md` với frontmatter sau:
```yaml
---
name: skill-name
description: One line — what it does and when to use it.
---
```
