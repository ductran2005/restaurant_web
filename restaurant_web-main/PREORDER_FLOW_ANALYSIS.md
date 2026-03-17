# Phân tích Luồng Logic: Pre-order đến Thanh toán

## Tổng quan Luồng nghiệp vụ

```
Customer Pre-order → Deposit Payment → Check-in → Seat → Create Order → Add Items → Serve → Checkout → Payment
```

---

## 1. CUSTOMER PRE-ORDER (Khách đặt món trước)

### 1.1. Điểm vào
- **URL**: `/customer/preorder?bookingCode=XXX` hoặc `/user/pre-order?code=XXX`
- **Controller**: `PreOrderController.java` / `PreOrderPageController.java`

### 1.2. Quy trình thêm món Pre-order

**Controller**: `PreOrderController.doPost()` - action="add"
```java
handleAdd(req) {
    int bookingId = req.getParameter("bookingId");
    int productId = req.getParameter("productId");
    int quantity = req.getParameter("quantity");
    String note = req.getParameter("note");
    
    preOrderService.addPreOrderItem(bookingId, productId, quantity, note);
}
```

**Service**: `PreOrderService.addPreOrderItem()`
```java
Validation checks:
1. Booking tồn tại?
2. Booking status = PENDING hoặc CONFIRMED? (canModifyPreOrder)
3. Pre-order chưa bị lock? (60 phút trước giờ đặt)
4. Product AVAILABLE?
5. Product đủ số lượng?

Logic:
- Nếu món đã có trong pre-order → Cộng thêm quantity
- Nếu món chưa có → Tạo PreOrderItem mới
- Tự động tính lại depositAmount = 10% tổng pre-order
- Update Booking.depositAmount
```

### 1.3. Database Changes
```sql
-- Tạo PreOrderItem
INSERT INTO pre_order_items (booking_id, product_id, quantity, note, created_at)
VALUES (?, ?, ?, ?, NOW());

-- Update Booking deposit
UPDATE bookings 
SET deposit_amount = (SELECT SUM(price * quantity) * 0.10 FROM pre_order_items WHERE booking_id = ?),
    updated_at = NOW()
WHERE booking_id = ?;
```

### 1.4. Business Rules
- ✅ Chỉ được thêm món khi Booking status = PENDING hoặc CONFIRMED
- ✅ Pre-order bị lock 60 phút trước giờ đặt bàn
- ✅ Deposit = 10% tổng giá trị pre-order
- ✅ Tự động remove món UNAVAILABLE (cleanupUnavailableItems)

---

## 2. DEPOSIT PAYMENT (Thanh toán tiền cọc)

### 2.1. Điểm vào
- **URL**: `/pre-order/checkout?code=XXX`
- **Controller**: `PreOrderCheckoutController.java`

### 2.2. Hiển thị thông tin thanh toán

**Controller**: `PreOrderCheckoutController.doGet()`
```java
Logic:
1. Load Booking với EAGER FETCH pre-order items và products
2. Tính toán:
   - subtotal = SUM(product.price * quantity)
   - deposit = subtotal * 10%
   - vat = subtotal * 10%
   - serviceFee = subtotal * 5%
   - grandTotal = subtotal + vat + serviceFee
3. Pass data to JSP: booking, items, subtotal, deposit, vat, serviceFee, grandTotal
```

**View**: `pre-order-checkout.jsp`
```jsp
Hiển thị:
- Danh sách món đã chọn (forEach items)
- Tạm tính, VAT, Phí dịch vụ
- Tổng dự kiến
- Số tiền cọc cần thanh toán (10%)
- QR Code thanh toán (SePay)
```

### 2.3. Xác nhận thanh toán

**Controller**: `PreOrderCheckoutController.doPost()` - method="TRANSFER"
```java
Logic:
1. Tìm Booking theo code
2. Tính lại deposit từ pre-order items
3. Update Booking:
   - depositStatus = "PAID"
   - depositRef = "TRANSFER-{timestamp}"
   - depositAmount = calculated deposit
4. Redirect về pre-order page với success message
```

### 2.4. Database Changes
```sql
UPDATE bookings 
SET deposit_status = 'PAID',
    deposit_ref = ?,
    deposit_amount = ?,
    updated_at = NOW()
WHERE booking_code = ?;
```

### 2.5. Business Rules
- ✅ Deposit = 10% tổng pre-order
- ✅ Deposit status: PENDING → PAID
- ✅ Nếu cancel trước 60 phút: PAID → REFUNDED
- ✅ Nếu cancel sau 60 phút: PAID → FORFEITED
- ✅ Nếu no-show: Deposit bị giữ lại

---

## 3. CHECK-IN (Khách đến nhà hàng)

### 3.1. Điểm vào
- **URL**: `/staff/bookings` (POST action=checkin)
- **Controller**: `BookingController.java`

### 3.2. Quy trình Check-in

**Controller**: `BookingController.doPost()` - action="checkin"
```java
bookingService.checkIn(bookingId);
```

**Service**: `BookingService.checkIn()`
```java
Validation:
1. Booking tồn tại?
2. Có bàn trống? (COUNT tables WHERE status = EMPTY OR AVAILABLE)

Logic:
- Update Booking.status = "CHECKED_IN"
- Update Booking.updatedAt = NOW()
```

### 3.3. Database Changes
```sql
UPDATE bookings 
SET status = 'CHECKED_IN',
    updated_at = NOW()
WHERE booking_id = ?;
```

### 3.4. Business Rules
- ✅ Phải có ít nhất 1 bàn trống mới được check-in
- ✅ Status flow: CONFIRMED → CHECKED_IN

---

## 4. ASSIGN TABLE & SEAT (Gán bàn và xếp chỗ)

### 4.1. Assign Table

**Service**: `BookingService.assignTable(bookingId, tableId)`
```java
Validation:
1. Booking và Table tồn tại?
2. Table capacity >= Booking.partySize?
3. Không có time conflict với booking khác?

Logic:
- Update Booking.table = table
- Update Table.status = RESERVED
```

### 4.2. Seat Customer

**Service**: `BookingService.seatCustomer(bookingId)`
```java
Validation:
1. Booking đã được assign table?

Logic:
- Update Booking.status = "SEATED"
- Update Table.status = OCCUPIED
```

### 4.3. Database Changes
```sql
-- Assign table
UPDATE bookings SET table_id = ?, updated_at = NOW() WHERE booking_id = ?;
UPDATE dining_tables SET status = 'RESERVED' WHERE table_id = ?;

-- Seat customer
UPDATE bookings SET status = 'SEATED', updated_at = NOW() WHERE booking_id = ?;
UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_id = ?;
```

### 4.4. Business Rules
- ✅ Status flow: CHECKED_IN → SEATED
- ✅ Table status: EMPTY → RESERVED → OCCUPIED
- ✅ Auto-assign: Tìm bàn nhỏ nhất phù hợp với party size

---

## 5. CREATE ORDER (Tạo Order từ bàn có Booking)

### 5.1. Điểm vào
- **URL**: `/staff/orders?action=create&tableId=X`
- **Controller**: `OrderEditorController.java`

### 5.2. Quy trình tạo Order

**Controller**: `OrderEditorController.doGet()` - action="create"
```java
User staff = session.getAttribute("user");
int tableId = req.getParameter("tableId");

Order existing = orderService.getOpenOrderByTable(tableId);
if (existing != null) {
    // Redirect to existing order
} else {
    Order order = orderService.createOrder(tableId, staff.getId());
    // Redirect to new order
}
```

**Service**: `OrderService.createOrder(tableId, staffId)` ⭐ **UPDATED**
```java
Validation:
1. Bàn chưa có Order OPEN nào?

Logic:
1. Tạo Order mới:
   - table = tableId
   - createdByUser = staffId
   - status = "OPEN"
   - orderType = "DINE_IN"

2. 🆕 Tìm Booking active của bàn:
   - Query: SELECT * FROM bookings 
            WHERE table_id = ? 
            AND status IN ('CHECKED_IN', 'SEATED')
            ORDER BY booking_date DESC, booking_time DESC
            LIMIT 1

3. 🆕 Nếu tìm thấy Booking:
   - Gán order.booking = booking
   
4. 🆕 Copy Pre-order items sang OrderDetail:
   - Duyệt qua booking.preOrderItems
   - Tạo OrderDetail cho mỗi PreOrderItem:
     * product = preItem.product
     * quantity = preItem.quantity
     * unitPrice = product.price (snapshot giá hiện tại)
     * itemStatus = "PENDING"
   - Persist OrderDetail
   
5. 🆕 Recalculate Order totals:
   - subtotal = SUM(orderDetail.lineTotal)
   - totalAmount = subtotal - discountAmount
   - Update Order

6. Update Table.status = OCCUPIED (if has items)
```

### 5.3. Database Changes
```sql
-- Create Order
INSERT INTO orders (table_id, created_by, status, order_type, opened_at, booking_id)
VALUES (?, ?, 'OPEN', 'DINE_IN', NOW(), ?);

-- Copy PreOrderItems to OrderDetails
INSERT INTO order_details (order_id, product_id, quantity, unit_price, item_status)
SELECT ?, product_id, quantity, (SELECT price FROM products WHERE product_id = poi.product_id), 'PENDING'
FROM pre_order_items poi
WHERE booking_id = ?;

-- Update Order totals
UPDATE orders 
SET subtotal = (SELECT SUM(line_total) FROM order_details WHERE order_id = ? AND item_status != 'CANCELLED'),
    total_amount = subtotal - discount_amount
WHERE order_id = ?;

-- Update Table status
UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_id = ?;
```

### 5.4. Business Rules
- ✅ 1 bàn chỉ có 1 Order OPEN tại một thời điểm
- ✅ 🆕 Tự động tìm Booking active (CHECKED_IN hoặc SEATED)
- ✅ 🆕 Tự động copy Pre-order items sang Order
- ✅ 🆕 Giá món = giá hiện tại (snapshot), không phải giá lúc đặt
- ✅ 🆕 ItemStatus = "PENDING" (cần confirm để gửi bếp)

---

## 6. ADD MORE ITEMS (Gọi thêm món)

### 6.1. Quy trình thêm món

**Service**: `OrderService.addItem(orderId, productId, qty)`
```java
Validation:
1. Order tồn tại và status = OPEN?
2. Product AVAILABLE?

Logic:
- Tạo OrderDetail mới
- itemStatus = "PENDING"
- Recalculate Order totals
- Update Table.status = OCCUPIED
```

### 6.2. Business Rules
- ✅ Chỉ thêm món khi Order status = OPEN
- ✅ Món phải AVAILABLE
- ✅ Tự động cập nhật tổng tiền

---

## 7. CONFIRM & SERVE (Xác nhận và phục vụ)

### 7.1. Confirm Items (Gửi bếp)

**Service**: `OrderService.confirmItems(orderId)`
```java
Logic:
- Update all OrderDetail WHERE itemStatus = 'PENDING'
- Set itemStatus = 'ORDERED'
```

### 7.2. Confirm Order (Yêu cầu thanh toán)

**Service**: `OrderService.confirmOrder(orderId)`
```java
Validation:
- Order status = OPEN?

Logic:
- Update Order.status = "SERVED"
- Update Table.status = WAITING_PAYMENT
```

### 7.3. Business Rules
- ✅ Status flow: PENDING → ORDERED (items)
- ✅ Status flow: OPEN → SERVED (order)
- ✅ Table status: OCCUPIED → WAITING_PAYMENT

---

## 8. CHECKOUT (Thu ngân thanh toán)

### 8.1. Điểm vào
- **URL**: `/cashier/checkout?orderId=X`
- **Controller**: `CheckoutController.java`

### 8.2. Hiển thị thông tin thanh toán

**Controller**: `CheckoutController.doGet()` ⭐ **UPDATED**
```java
Validation:
- Order tồn tại và status = SERVED?

Logic:
1. Load Order với OrderDetails
2. 🆕 Tính toán tiền cọc:
   - depositAmount = 0
   - grandTotal = order.totalAmount
   - finalAmountToPay = grandTotal
   
   - IF order.booking != null AND order.booking.depositAmount != null:
     * depositAmount = order.booking.depositAmount
     * finalAmountToPay = grandTotal - depositAmount
     * IF finalAmountToPay < 0: finalAmountToPay = 0

3. Pass to JSP:
   - order
   - depositAmount 🆕
   - finalAmountToPay 🆕
   - SePay config
```

**View**: `checkout.jsp` ⭐ **UPDATED**
```jsp
Hiển thị:
- Danh sách món (OrderDetails WHERE itemStatus = 'ORDERED')
- Tạm tính (subtotal)
- Giảm giá (discountAmount)
- Tổng cộng (totalAmount)
- 🆕 Tiền đã cọc (-depositAmount) [màu xanh, icon check]
- 🆕 Cần thanh toán (finalAmountToPay) [in đậm]
- 🆕 QR Code với amount = finalAmountToPay
```

### 8.3. Xác nhận thanh toán

**Controller**: `CheckoutController.doPost()` - action="pay"
```java
Logic:
1. Tạo Payment record:
   - order_id = orderId
   - method = paymentMethod (CASH/CARD/TRANSFER)
   - amount = order.totalAmount (⚠️ Chưa trừ deposit)
   - cashier_id = cashier.id
   - payment_date = NOW()
   - status = "COMPLETED"

2. Update Order:
   - status = "PAID"
   - closedAt = NOW()

3. Update Table:
   - status = "DIRTY"
```

### 8.4. Database Changes
```sql
-- Create Payment
INSERT INTO payments (order_id, method, amount, cashier_id, payment_date, status)
VALUES (?, ?, ?, ?, NOW(), 'COMPLETED');

-- Update Order
UPDATE orders 
SET status = 'PAID',
    closed_at = NOW()
WHERE order_id = ?;

-- Update Table
UPDATE dining_tables SET status = 'DIRTY' WHERE table_id = ?;
```

### 8.5. Business Rules
- ✅ Chỉ thanh toán khi Order status = SERVED
- ✅ 🆕 Hiển thị tiền cọc đã trừ
- ✅ 🆕 QR Code hiển thị số tiền sau khi trừ cọc
- ⚠️ **ISSUE**: Payment.amount vẫn lưu full amount, chưa trừ deposit

---

## 9. COMPLETE BOOKING (Hoàn thành)

### 9.1. Quy trình hoàn thành

**Service**: `BookingService.complete(bookingId)`
```java
Logic:
- Update Booking.status = "COMPLETED"
- Note: Table status = DIRTY (handled by payment)
```

### 9.2. Business Rules
- ✅ Status flow: SEATED → COMPLETED
- ✅ Table status: WAITING_PAYMENT → DIRTY → EMPTY (after cleaning)

---

## 10. ISSUES & RECOMMENDATIONS

### 10.1. ⚠️ Critical Issues

**Issue 1: Payment amount không trừ deposit**
```java
// CheckoutController.doPost() - CURRENT
Payment payment = paymentService.checkout(orderId, method, cashier.getId());
// → PaymentService lưu payment.amount = order.totalAmount (chưa trừ deposit)

// RECOMMENDATION: Truyền finalAmountToPay vào PaymentService
BigDecimal finalAmount = calculateFinalAmount(order);
Payment payment = paymentService.checkout(orderId, method, cashier.getId(), finalAmount);
```

**Issue 2: Booking.depositStatus không được update sau thanh toán**
```java
// RECOMMENDATION: Sau khi thanh toán thành công
if (order.getBooking() != null && order.getBooking().getDepositAmount().compareTo(BigDecimal.ZERO) > 0) {
    Booking booking = order.getBooking();
    booking.setDepositStatus("APPLIED"); // hoặc "USED"
    bookingDao.update(session, booking);
}
```

### 10.2. ✅ Working Features

1. ✅ Pre-order items được copy sang Order khi tạo Order
2. ✅ Deposit được tính và hiển thị đúng
3. ✅ QR Code hiển thị số tiền sau khi trừ cọc
4. ✅ UI hiển thị rõ ràng tiền cọc và số tiền cần thanh toán
5. ✅ Booking status flow hoạt động đúng
6. ✅ Table status flow hoạt động đúng

### 10.3. 🔧 Suggested Improvements

**1. Update PaymentService.checkout() signature**
```java
// OLD
public Payment checkout(int orderId, String method, int cashierId)

// NEW
public Payment checkout(int orderId, String method, int cashierId, BigDecimal actualAmount)
```

**2. Add depositStatus tracking**
```sql
-- Add new status value
ALTER TABLE bookings 
ADD CONSTRAINT check_deposit_status 
CHECK (deposit_status IN ('PENDING', 'PAID', 'REFUNDED', 'FORFEITED', 'APPLIED'));
```

**3. Add audit trail**
```java
// Log deposit application
System.out.println("Applied deposit " + depositAmount + " from booking " + 
    booking.getBookingCode() + " to order #" + order.getId());
```

---

## 11. COMPLETE FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. CUSTOMER PRE-ORDER                                               │
│    - Add items to booking                                           │
│    - depositAmount = 10% * pre-order total                          │
│    - depositStatus = PENDING                                        │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 2. DEPOSIT PAYMENT                                                  │
│    - Customer pays deposit via QR/Transfer                          │
│    - depositStatus = PAID                                           │
│    - depositRef = transaction ID                                    │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 3. CHECK-IN                                                         │
│    - Customer arrives at restaurant                                 │
│    - Booking.status = CHECKED_IN                                    │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 4. ASSIGN TABLE & SEAT                                              │
│    - Assign table to booking                                        │
│    - Booking.status = SEATED                                        │
│    - Table.status = OCCUPIED                                        │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 5. CREATE ORDER 🆕                                                  │
│    - Find active booking by table_id                                │
│    - Link Order.booking_id = booking.id                             │
│    - Copy PreOrderItems → OrderDetails (status=PENDING)             │
│    - Recalculate Order totals                                       │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 6. ADD MORE ITEMS (Optional)                                        │
│    - Staff adds more items to order                                 │
│    - Recalculate totals                                             │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 7. CONFIRM & SERVE                                                  │
│    - Confirm items (PENDING → ORDERED)                              │
│    - Confirm order (OPEN → SERVED)                                  │
│    - Table.status = WAITING_PAYMENT                                 │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 8. CHECKOUT 🆕                                                      │
│    - Calculate: finalAmount = totalAmount - depositAmount           │
│    - Display deposit deduction in UI                                │
│    - QR Code shows finalAmount                                      │
│    - Create Payment record                                          │
│    - Order.status = PAID                                            │
│    - Table.status = DIRTY                                           │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 9. COMPLETE                                                         │
│    - Booking.status = COMPLETED                                     │
│    - Clean table → Table.status = EMPTY                             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 12. STATUS TRANSITIONS

### Booking Status
```
PENDING → CONFIRMED → CHECKED_IN → SEATED → COMPLETED
         ↓
      CANCELLED / NO_SHOW
```

### Deposit Status
```
PENDING → PAID → APPLIED (after payment)
         ↓
      REFUNDED (cancel before cutoff)
         ↓
      FORFEITED (cancel after cutoff / no-show)
```

### Order Status
```
OPEN → SERVED → PAID
      ↓
   CANCELLED
```

### OrderDetail ItemStatus
```
PENDING → ORDERED
         ↓
      CANCELLED
```

### Table Status
```
EMPTY → RESERVED → OCCUPIED → WAITING_PAYMENT → DIRTY → EMPTY
```

---

## 13. KEY TAKEAWAYS

✅ **Đã hoàn thành**:
1. Pre-order items tự động copy sang Order
2. Deposit được tính và hiển thị đúng
3. UI checkout hiển thị tiền cọc và số tiền cần thanh toán
4. QR Code hiển thị số tiền đã trừ cọc

⚠️ **Cần cải thiện**:
1. Payment.amount cần lưu số tiền thực tế (sau khi trừ cọc)
2. Booking.depositStatus cần update thành "APPLIED" sau thanh toán
3. Thêm audit log cho việc apply deposit

📝 **Lưu ý**:
- Giá món trong OrderDetail = giá hiện tại (snapshot), không phải giá lúc đặt
- Pre-order bị lock 60 phút trước giờ đặt bàn
- Deposit = 10% tổng pre-order
- Deposit được refund nếu cancel trước 60 phút
