/* =========================================================
   Test Script for Auto-Cancel Late Bookings
   ========================================================= */

USE Restaurant_Ipos;
GO

-- =========================================================
-- 1. CREATE TEST BOOKINGS
-- =========================================================

DECLARE @STAFF_ID INT = (SELECT user_id FROM users WHERE username='staff1');
DECLARE @TABLE_T01 INT = (SELECT table_id FROM tables WHERE table_name='T01');
DECLARE @TABLE_T02 INT = (SELECT table_id FROM tables WHERE table_name='T02');
DECLARE @TABLE_T03 INT = (SELECT table_id FROM tables WHERE table_name='T03');

PRINT '=== Creating test bookings ===';

-- Test Case 1: Booking trễ 25 phút (SẼ BỊ HỦY)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-001',
    N'Test Late 25min',
    '0999999991',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -25, GETDATE()) AS TIME),
    2,
    'CONFIRMED',
    @TABLE_T01,
    @STAFF_ID,
    DATEADD(MINUTE, -30, SYSDATETIME())
);
PRINT '✓ Created TEST-LATE-001 (late 25 minutes - WILL BE CANCELLED)';

-- Test Case 2: Booking trễ 15 phút (KHÔNG BỊ HỦY - chưa đủ 20 phút)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-002',
    N'Test Late 15min',
    '0999999992',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -15, GETDATE()) AS TIME),
    2,
    'CONFIRMED',
    @TABLE_T02,
    @STAFF_ID,
    DATEADD(MINUTE, -20, SYSDATETIME())
);
PRINT '✓ Created TEST-LATE-002 (late 15 minutes - WILL NOT BE CANCELLED)';

-- Test Case 3: Booking đã check-in (KHÔNG BỊ HỦY - đã check-in)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-003',
    N'Test Checked In',
    '0999999993',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -30, GETDATE()) AS TIME),
    2,
    'CHECKED_IN',
    @TABLE_T03,
    @STAFF_ID,
    DATEADD(MINUTE, -35, SYSDATETIME())
);
PRINT '✓ Created TEST-LATE-003 (checked in - WILL NOT BE CANCELLED)';

-- Test Case 4: Booking trễ 20 phút đúng (SẼ BỊ HỦY)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-004',
    N'Test Late Exactly 20min',
    '0999999994',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -20, GETDATE()) AS TIME),
    2,
    'CONFIRMED',
    NULL, -- Không có bàn
    @STAFF_ID,
    DATEADD(MINUTE, -25, SYSDATETIME())
);
PRINT '✓ Created TEST-LATE-004 (late exactly 20 minutes, no table - WILL BE CANCELLED)';

PRINT '';
PRINT '=== Test bookings created successfully ===';
PRINT '';

-- =========================================================
-- 2. CHECK BEFORE AUTO-CANCEL
-- =========================================================

PRINT '=== Status BEFORE auto-cancel ===';
SELECT 
    booking_code,
    status,
    booking_time,
    table_id,
    DATEDIFF(MINUTE, 
        CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2),
        GETDATE()
    ) AS minutes_late,
    CASE 
        WHEN DATEDIFF(MINUTE, 
            CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2),
            GETDATE()
        ) >= 20 AND status = 'CONFIRMED' THEN 'WILL BE CANCELLED'
        ELSE 'WILL NOT BE CANCELLED'
    END AS expected_result
FROM bookings 
WHERE booking_code LIKE 'TEST-LATE-%'
ORDER BY booking_code;

PRINT '';
PRINT '=== Now run auto-cancel via web UI or wait for scheduler ===';
PRINT 'URL: http://localhost:8080/restaurant_web/staff/test-auto-cancel';
PRINT '';

-- =========================================================
-- 3. CHECK AFTER AUTO-CANCEL (Run this after triggering)
-- =========================================================

/*
PRINT '=== Status AFTER auto-cancel ===';
SELECT 
    booking_code,
    status,
    cancel_reason,
    table_id,
    updated_at
FROM bookings 
WHERE booking_code LIKE 'TEST-LATE-%'
ORDER BY booking_code;

-- Expected results:
-- TEST-LATE-001: CANCELLED (late 25 minutes)
-- TEST-LATE-002: CONFIRMED (only 15 minutes late)
-- TEST-LATE-003: CHECKED_IN (already checked in)
-- TEST-LATE-004: CANCELLED (late 20 minutes, no table)

PRINT '';
PRINT '=== Check tables status ===';
SELECT t.table_name, t.status
FROM tables t
WHERE t.table_name IN ('T01', 'T02', 'T03')
ORDER BY t.table_name;

-- Expected:
-- T01: EMPTY (freed from TEST-LATE-001)
-- T02: RESERVED (still assigned to TEST-LATE-002)
-- T03: OCCUPIED (still assigned to TEST-LATE-003)
*/

-- =========================================================
-- 4. CLEANUP (Run after testing)
-- =========================================================

/*
PRINT '=== Cleaning up test bookings ===';
DELETE FROM bookings WHERE booking_code LIKE 'TEST-LATE-%';
PRINT '✓ Test bookings deleted';
*/

GO
