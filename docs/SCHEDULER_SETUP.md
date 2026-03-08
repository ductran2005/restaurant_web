# Scheduler Setup Guide

## Vấn đề

`BookingScheduler` chạy trong Java app (ServletContextListener) sẽ bị gián đoạn khi:
- App deploy lên free hosting (Render, Railway, Heroku) bị sleep sau 15-30 phút không hoạt động
- Server restart hoặc maintenance
- App crash

## Giải pháp

Có 3 cách để đảm bảo scheduler chạy liên tục:

---

## Cách 1: External Cron Service (Khuyến nghị cho bắt đầu)

### Ưu điểm:
- ✅ Đơn giản, không cần code thêm
- ✅ Miễn phí
- ✅ Keep app alive (tránh sleep)
- ✅ Setup nhanh 5 phút

### Nhược điểm:
- ⚠️ Phụ thuộc service bên thứ 3
- ⚠️ App vẫn phải online để xử lý

### Bước 1: Tạo Scheduler Endpoint

Tạo file `src/main/java/market/restaurant_web/controller/api/SchedulerApiController.java`:

```java
package market.restaurant_web.controller.api;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.PreOrderService;
import market.restaurant_web.entity.Booking;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * API endpoint for external cron to trigger scheduler tasks
 * URL: /api/scheduler/run
 * Method: POST
 * Auth: API Key in header X-API-Key
 */
@WebServlet("/api/scheduler/run")
public class SchedulerApiController extends HttpServlet {
    
    private final BookingService bookingService = new BookingService();
    private final PreOrderService preOrderService = new PreOrderService();
    
    // TODO: Change this to a secure random key in production
    private static final String API_KEY = "your-secret-api-key-change-this";
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        try {
            // Verify API key
            String apiKey = req.getHeader("X-API-Key");
            if (apiKey == null || !apiKey.equals(API_KEY)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.println("{\"error\": \"Unauthorized\", \"message\": \"Invalid API key\"}");
                return;
            }
            
            System.out.println("\n>>> External Cron triggered at: " + java.time.LocalDateTime.now());
            
            // Run scheduler tasks
            StringBuilder result = new StringBuilder();
            result.append("{\"status\": \"success\", \"tasks\": [");
            
            // Task 1: Auto-assign tables
            try {
                bookingService.autoAssignTablesForUpcomingBookings(60);
                result.append("{\"task\": \"auto_assign_tables\", \"status\": \"completed\"},");
            } catch (Exception e) {
                result.append("{\"task\": \"auto_assign_tables\", \"status\": \"failed\", \"error\": \"")
                      .append(e.getMessage()).append("\"},");
            }
            
            // Task 2: Update table status to RESERVED
            try {
                bookingService.updateTableStatusForUpcomingBookings(30);
                result.append("{\"task\": \"update_table_status\", \"status\": \"completed\"},");
            } catch (Exception e) {
                result.append("{\"task\": \"update_table_status\", \"status\": \"failed\", \"error\": \"")
                      .append(e.getMessage()).append("\"},");
            }
            
            // Task 3: Auto-cancel late bookings
            try {
                bookingService.autoCancelLateBookings(20);
                result.append("{\"task\": \"auto_cancel_late\", \"status\": \"completed\"},");
            } catch (Exception e) {
                result.append("{\"task\": \"auto_cancel_late\", \"status\": \"failed\", \"error\": \"")
                      .append(e.getMessage()).append("\"},");
            }
            
            // Task 4: Lock pre-orders
            try {
                List<Booking> bookings = preOrderService.getBookingsToLock();
                for (Booking booking : bookings) {
                    preOrderService.lockPreOrder(booking.getId());
                }
                result.append("{\"task\": \"lock_preorders\", \"status\": \"completed\", \"count\": ")
                      .append(bookings.size()).append("},");
            } catch (Exception e) {
                result.append("{\"task\": \"lock_preorders\", \"status\": \"failed\", \"error\": \"")
                      .append(e.getMessage()).append("\"},");
            }
            
            // Task 5: Cleanup unavailable items
            try {
                List<Booking> activeBookings = bookingService.findByDateAndStatus(
                    java.time.LocalDate.now(), "CONFIRMED"
                );
                int cleaned = 0;
                for (Booking booking : activeBookings) {
                    if (booking.getPreOrderItems() != null && !booking.getPreOrderItems().isEmpty()) {
                        preOrderService.cleanupUnavailableItems(booking.getId());
                        cleaned++;
                    }
                }
                result.append("{\"task\": \"cleanup_items\", \"status\": \"completed\", \"count\": ")
                      .append(cleaned).append("}");
            } catch (Exception e) {
                result.append("{\"task\": \"cleanup_items\", \"status\": \"failed\", \"error\": \"")
                      .append(e.getMessage()).append("\"}");
            }
            
            result.append("], \"timestamp\": \"").append(java.time.LocalDateTime.now()).append("\"}");
            
            System.out.println("<<< External Cron completed\n");
            
            resp.setStatus(HttpServletResponse.SC_OK);
            out.println(result.toString());
            
        } catch (Exception e) {
            System.err.println("Error in scheduler API: " + e.getMessage());
            e.printStackTrace();
            
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println("{\"error\": \"Internal server error\", \"message\": \"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        PrintWriter out = resp.getWriter();
        out.println("{\"message\": \"Scheduler API is running. Use POST method to trigger.\"}");
    }
}
```

### Bước 2: Setup Cron-Job.org (Miễn phí)

1. **Đăng ký tài khoản**: https://cron-job.org/en/signup/
2. **Tạo Cron Job mới**:
   - Click "Create cronjob"
   - Title: `Restaurant Scheduler`
   - URL: `https://your-app-domain.com/api/scheduler/run`
   - Schedule: `*/5 * * * *` (mỗi 5 phút)
   - Request method: `POST`
   - Headers: Add `X-API-Key: your-secret-api-key-change-this`
   - Save

3. **Test**: Click "Run now" để test ngay

### Bước 3: Thay đổi API Key

Trong `SchedulerApiController.java`, đổi:
```java
private static final String API_KEY = "your-secret-api-key-change-this";
```

Thành một key ngẫu nhiên mạnh, ví dụ:
```java
private static final String API_KEY = "sk_live_abc123xyz789_secure_key_2026";
```

### Bước 4: Vô hiệu hóa ServletContextListener (Optional)

Nếu muốn chỉ dùng external cron, comment out `@WebListener` trong `BookingScheduler.java`:

```java
// @WebListener  // Commented out - using external cron instead
public class BookingScheduler implements ServletContextListener {
    // ...
}
```

---

## Cách 2: Supabase Edge Functions + Cron (Mạnh mẽ hơn)

### Ưu điểm:
- ✅ Không phụ thuộc Java app (chạy độc lập)
- ✅ Truy cập database trực tiếp
- ✅ Serverless, auto-scale
- ✅ Tích hợp sẵn với Supabase

### Nhược điểm:
- ⚠️ Cần viết code TypeScript/JavaScript
- ⚠️ Cần học Supabase Edge Functions
- ⚠️ Cron chỉ có trên Supabase Pro ($25/tháng)

### Bước 1: Cài đặt Supabase CLI

```bash
# Windows (PowerShell)
scoop install supabase

# hoặc dùng npm
npm install -g supabase
```

### Bước 2: Khởi tạo project

```bash
# Trong thư mục project
supabase init

# Login vào Supabase
supabase login
```

### Bước 3: Tạo Edge Function

```bash
supabase functions new booking-scheduler
```

Tạo file `supabase/functions/booking-scheduler/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    console.log('>>> Scheduler running at:', new Date().toISOString())

    const results = {
      autoAssignTables: await autoAssignTables(supabase),
      autoCancelLate: await autoCancelLateBookings(supabase),
      lockPreOrders: await lockPreOrders(supabase),
    }

    console.log('<<< Scheduler completed')

    return new Response(
      JSON.stringify({ success: true, results, timestamp: new Date().toISOString() }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Auto-assign tables for bookings 60 mins before
async function autoAssignTables(supabase: any) {
  const now = new Date()
  const targetTime = new Date(now.getTime() + 60 * 60 * 1000) // +60 mins

  // Get CONFIRMED bookings without table
  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*, tables(*)')
    .eq('status', 'CONFIRMED')
    .is('table_id', null)
    .gte('booking_date', now.toISOString().split('T')[0])

  if (error) throw error

  let assigned = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    
    if (bookingDateTime > now && bookingDateTime < targetTime) {
      // Find best available table
      const { data: tables } = await supabase
        .from('tables')
        .select('*')
        .gte('capacity', booking.party_size)
        .order('capacity', { ascending: true })

      if (tables && tables.length > 0) {
        const table = tables[0]
        
        // Assign table
        await supabase
          .from('bookings')
          .update({ table_id: table.table_id, updated_at: new Date() })
          .eq('booking_id', booking.booking_id)

        // Set table to RESERVED
        await supabase
          .from('tables')
          .update({ status: 'RESERVED' })
          .eq('table_id', table.table_id)

        assigned++
        console.log(`Assigned table ${table.table_name} to booking ${booking.booking_code}`)
      }
    }
  }

  return { assigned }
}

// Auto-cancel bookings 20+ mins late
async function autoCancelLateBookings(supabase: any) {
  const now = new Date()
  const cutoffTime = new Date(now.getTime() - 20 * 60 * 1000) // -20 mins

  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*, pre_order_items(*)')
    .eq('status', 'CONFIRMED')

  if (error) throw error

  let cancelled = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    const hasPreOrder = booking.pre_order_items && booking.pre_order_items.length > 0
    const graceMinutes = hasPreOrder ? 40 : 20
    const cancelTime = new Date(bookingDateTime.getTime() + graceMinutes * 60 * 1000)

    if (now > cancelTime) {
      // Cancel booking
      const updates: any = {
        status: 'CANCELLED',
        cancel_reason: `Tự động hủy: Khách không đến sau ${graceMinutes} phút`,
        updated_at: new Date()
      }

      // Forfeit deposit if has pre-order
      if (hasPreOrder && booking.deposit_status === 'PAID') {
        updates.deposit_status = 'FORFEITED'
      }

      await supabase
        .from('bookings')
        .update(updates)
        .eq('booking_id', booking.booking_id)

      // Free table if assigned
      if (booking.table_id) {
        await supabase
          .from('tables')
          .update({ status: 'EMPTY' })
          .eq('table_id', booking.table_id)
      }

      cancelled++
      console.log(`Auto-cancelled booking ${booking.booking_code}`)
    }
  }

  return { cancelled }
}

// Lock pre-orders 60 mins before booking
async function lockPreOrders(supabase: any) {
  const now = new Date()
  const lockTime = new Date(now.getTime() + 60 * 60 * 1000) // +60 mins

  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*')
    .in('status', ['PENDING', 'CONFIRMED'])
    .is('preorder_locked_at', null)

  if (error) throw error

  let locked = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    
    if (bookingDateTime <= lockTime) {
      await supabase
        .from('bookings')
        .update({ preorder_locked_at: new Date() })
        .eq('booking_id', booking.booking_id)

      locked++
      console.log(`Locked pre-order for booking ${booking.booking_code}`)
    }
  }

  return { locked }
}
```

### Bước 4: Deploy Edge Function

```bash
# Deploy function
supabase functions deploy booking-scheduler

# Test function
supabase functions invoke booking-scheduler
```

### Bước 5: Setup Cron (Supabase Pro)

1. Vào Supabase Dashboard > Database > Cron Jobs
2. Tạo job mới:
   - Name: `booking-scheduler`
   - Schedule: `*/5 * * * *` (mỗi 5 phút)
   - Command:
   ```sql
   SELECT net.http_post(
     url := 'https://your-project-ref.supabase.co/functions/v1/booking-scheduler',
     headers := '{"Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
   );
   ```

### Bước 6: Alternative - Dùng pg_cron (Free)

Nếu không có Supabase Pro, dùng pg_cron extension:

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create cron job (chạy mỗi 5 phút)
SELECT cron.schedule(
  'booking-scheduler',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url := 'https://your-project-ref.supabase.co/functions/v1/booking-scheduler',
    headers := '{"Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
  );
  $$
);
```

---

## Cách 3: Upgrade Hosting (Đơn giản nhất)

### Render ($7/tháng)
- App không bao giờ sleep
- Scheduler Java chạy bình thường
- Không cần setup gì thêm

### Railway ($5/tháng)
- Tương tự Render
- Có $5 credit miễn phí mỗi tháng

---

## So sánh các cách

| Tiêu chí | External Cron | Supabase Edge | Paid Hosting |
|----------|--------------|---------------|--------------|
| Chi phí | Miễn phí | $25/tháng | $5-7/tháng |
| Độ khó setup | Dễ (5 phút) | Trung bình | Rất dễ |
| Độ tin cậy | Cao | Rất cao | Cao |
| Phụ thuộc app | Có | Không | Có |
| Code thêm | Ít | Nhiều | Không |

## Khuyến nghị

1. **Bắt đầu**: Dùng External Cron (Cron-Job.org) - miễn phí, dễ setup
2. **Production nhỏ**: Upgrade hosting ($5-7/tháng) - đơn giản nhất
3. **Production lớn**: Supabase Edge Functions - mạnh mẽ, scalable

---

## Testing

### Test External Cron API

```bash
# Windows PowerShell
$headers = @{
    "X-API-Key" = "your-secret-api-key-change-this"
    "Content-Type" = "application/json"
}

Invoke-WebRequest -Uri "http://localhost:8080/api/scheduler/run" -Method POST -Headers $headers
```

### Test Supabase Edge Function

```bash
supabase functions invoke booking-scheduler --no-verify-jwt
```

### Monitor Logs

**External Cron**: Xem log trong Cron-Job.org dashboard
**Edge Functions**: `supabase functions logs booking-scheduler`
**Java App**: Xem console log hoặc application log file
