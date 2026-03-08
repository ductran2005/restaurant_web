# Scheduler Quick Start Guide

## Chọn giải pháp phù hợp

### 🚀 Khuyến nghị: External Cron (5 phút setup)

Phù hợp cho:
- Bắt đầu nhanh
- Budget thấp (miễn phí)
- Không muốn code thêm

---

## Setup External Cron (Cron-Job.org)

### Bước 1: Thay đổi API Key (2 phút)

Mở file `src/main/java/market/restaurant_web/controller/api/SchedulerApiController.java`

Tìm dòng:
```java
private static final String API_KEY = "your-secret-api-key-change-this";
```

Đổi thành một key ngẫu nhiên mạnh:
```java
private static final String API_KEY = "sk_live_abc123xyz789_secure_key_2026";
```

💡 Tạo key ngẫu nhiên: https://www.uuidgenerator.net/

### Bước 2: Build và Deploy (3 phút)

```bash
# Build project
mvn clean package -DskipTests

# Deploy lên server (Render, Railway, etc.)
# Hoặc chạy local để test
mvn tomcat7:run
```

### Bước 3: Đăng ký Cron-Job.org (2 phút)

1. Vào https://cron-job.org/en/signup/
2. Đăng ký tài khoản miễn phí
3. Xác nhận email

### Bước 4: Tạo Cron Job (3 phút)

1. Click **"Create cronjob"**
2. Điền thông tin:

```
Title: Restaurant Scheduler
URL: https://your-app-domain.com/api/scheduler/run
Schedule: */5 * * * * (Every 5 minutes)
Request method: POST
```

3. Click **"Headers"** tab, thêm:
```
Header name: X-API-Key
Value: sk_live_abc123xyz789_secure_key_2026
```
(Dùng key bạn đã tạo ở Bước 1)

4. Click **"Save"**

### Bước 5: Test (1 phút)

1. Click **"Run now"** để test ngay
2. Xem kết quả trong tab **"History"**
3. Kiểm tra log của app để xác nhận scheduler đã chạy

✅ **Xong!** Scheduler sẽ tự động chạy mỗi 5 phút.

---

## Test Local

### Test bằng PowerShell:

```powershell
$headers = @{
    "X-API-Key" = "sk_live_abc123xyz789_secure_key_2026"
    "Content-Type" = "application/json"
}

Invoke-WebRequest -Uri "http://localhost:8080/api/scheduler/run" -Method POST -Headers $headers
```

### Test bằng curl:

```bash
curl -X POST http://localhost:8080/api/scheduler/run \
  -H "X-API-Key: sk_live_abc123xyz789_secure_key_2026"
```

### Kết quả mong đợi:

```json
{
  "status": "success",
  "tasks": [
    {"task": "auto_assign_tables", "status": "completed"},
    {"task": "update_table_status", "status": "completed"},
    {"task": "auto_cancel_late", "status": "completed"},
    {"task": "lock_preorders", "status": "completed", "count": 0},
    {"task": "cleanup_items", "status": "completed", "count": 0}
  ],
  "timestamp": "2026-03-08T22:15:00"
}
```

---

## Monitoring

### Xem log trong Cron-Job.org:

1. Vào dashboard
2. Click vào job "Restaurant Scheduler"
3. Tab **"History"** - xem lịch sử chạy
4. Tab **"Logs"** - xem response từ API

### Xem log trong app:

- Console log sẽ hiển thị:
```
========================================
>>> External Cron triggered at: 2026-03-08T22:15:00
>>> Remote IP: 123.45.67.89
========================================

[Task 1] Auto-assigning tables...
[Task 1] ✓ Completed

[Task 2] Updating table status to RESERVED...
[Task 2] ✓ Completed

...

========================================
<<< External Cron completed successfully
========================================
```

---

## Troubleshooting

### ❌ Error: "Unauthorized"

**Nguyên nhân**: API key không đúng

**Giải pháp**:
1. Kiểm tra API key trong `SchedulerApiController.java`
2. Kiểm tra header `X-API-Key` trong Cron-Job.org
3. Đảm bảo 2 key giống nhau

### ❌ Error: "Connection timeout"

**Nguyên nhân**: App không online hoặc URL sai

**Giải pháp**:
1. Kiểm tra app đang chạy: `curl https://your-app-domain.com/api/scheduler/run`
2. Kiểm tra URL trong Cron-Job.org
3. Kiểm tra firewall/security group

### ❌ Tasks failed

**Nguyên nhân**: Lỗi database hoặc logic

**Giải pháp**:
1. Xem log chi tiết trong console
2. Kiểm tra database connection
3. Kiểm tra dữ liệu test

---

## Vô hiệu hóa Internal Scheduler (Optional)

Nếu muốn chỉ dùng external cron, comment out `@WebListener`:

File: `src/main/java/market/restaurant_web/scheduler/BookingScheduler.java`

```java
// @WebListener  // Commented out - using external cron instead
public class BookingScheduler implements ServletContextListener {
    // ...
}
```

Rebuild:
```bash
mvn clean package -DskipTests
```

---

## Alternative: Supabase Edge Functions

Nếu muốn giải pháp mạnh mẽ hơn (không phụ thuộc Java app), xem:
- `docs/SCHEDULER_SETUP.md` - Hướng dẫn chi tiết
- `supabase/functions/README.md` - Setup Edge Functions

---

## Checklist

- [ ] Đổi API key trong `SchedulerApiController.java`
- [ ] Build và deploy app
- [ ] Đăng ký Cron-Job.org
- [ ] Tạo cron job với schedule `*/5 * * * *`
- [ ] Thêm header `X-API-Key`
- [ ] Test bằng "Run now"
- [ ] Kiểm tra log
- [ ] Monitor trong 24h đầu

---

## Support

Nếu gặp vấn đề:
1. Xem log chi tiết trong app console
2. Xem history trong Cron-Job.org
3. Test local bằng curl/PowerShell
4. Đọc `docs/SCHEDULER_SETUP.md` để biết thêm chi tiết
