# Hướng dẫn Tích hợp Pre-order vào Order và Thanh toán

## Tổng quan
Tài liệu này mô tả các thay đổi đã được thực hiện để tự động liên kết dữ liệu Pre-order (đặt trước) vào luồng Order (gọi món tại bàn) và thanh toán.

## Các thay đổi đã thực hiện

### 1. Cập nhật Entity và Database

#### 1.1. Order.java
- **Thêm quan hệ với Booking**: Thêm trường `booking` với annotation `@ManyToOne` và `@JoinColumn(name = "booking_id")`
- **Thêm Getter/Setter**: `getBooking()` và `setBooking(Booking booking)`
- Quan hệ này cho phép null vì không phải Order nào cũng từ Booking

#### 1.2. Database Migration
File: `database/migration_add_booking_to_order.sql`
```sql
ALTER TABLE orders ADD COLUMN booking_id INT NULL;
ALTER TABLE orders ADD CONSTRAINT fk_orders_booking 
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL;
CREATE INDEX idx_orders_booking_id ON orders(booking_id);
```

**Cách chạy migration:**
```bash
# PostgreSQL
psql -U [username] -d [database_name] -f database/migration_add_booking_to_order.sql

# Hoặc từ psql console
\i database/migration_add_booking_to_order.sql
```

### 2. Tìm Booking khi tạo Order

#### 2.1. BookingDao.java
Thêm phương thức `findActiveBookingByTable(Session s, int tableId)`:
- Tìm Booking đang active (status = 'CHECKED_IN' hoặc 'SEATED') của một bàn
- Sắp xếp theo ngày và giờ đặt bàn mới nhất
- Trả về booking đầu tiên tìm thấy

#### 2.2. BookingService.java
Thêm phương thức public `findActiveBookingByTable(int tableId)`:
- Wrapper method gọi BookingDao
- Sử dụng try-with-resources để quản lý Session

### 3. Tự động thêm món từ Pre-order vào Order

#### 3.1. OrderService.java - createOrder()
Cập nhật logic tạo Order:

1. **Tìm Booking active**: Gọi `bookingDao.findActiveBookingByTable(s, tableId)`
2. **Liên kết Booking**: Nếu tìm thấy, gán `order.setBooking(booking)`
3. **Copy PreOrderItem sang OrderDetail**:
   - Duyệt qua `booking.getPreOrderItems()`
   - Tạo OrderDetail mới cho mỗi PreOrderItem
   - Set các thuộc tính:
     - `product`: từ PreOrderItem
     - `quantity`: từ PreOrderItem
     - `unitPrice`: snapshot giá hiện tại từ Product
     - `itemStatus`: "PENDING" (có thể đổi thành "ORDERED" tùy policy)
   - Persist OrderDetail vào database
4. **Tính lại tổng tiền**: Gọi `recalculateOrder(s, order)` để cập nhật subtotal và totalAmount

### 4. Trừ tiền cọc lúc Thanh toán

#### 4.1. CheckoutController.java - doGet()
Cập nhật logic tính toán:

```java
// Tính tiền cọc và số tiền cuối cùng cần thanh toán
BigDecimal depositAmount = BigDecimal.ZERO;
BigDecimal grandTotal = order.getTotalAmount();
BigDecimal finalAmountToPay = grandTotal;

if (order.getBooking() != null && order.getBooking().getDepositAmount() != null) {
    depositAmount = order.getBooking().getDepositAmount();
    finalAmountToPay = grandTotal.subtract(depositAmount);
    // Đảm bảo không âm
    if (finalAmountToPay.compareTo(BigDecimal.ZERO) < 0) {
        finalAmountToPay = BigDecimal.ZERO;
    }
}

req.setAttribute("depositAmount", depositAmount);
req.setAttribute("finalAmountToPay", finalAmountToPay);
```

#### 4.2. checkout.jsp
Cập nhật giao diện hiển thị:

1. **Money Breakdown**: Thêm dòng hiển thị tiền đã cọc
```jsp
<c:if test="${depositAmount != null && depositAmount > 0}">
    <div class="breakdown-row" style="color: var(--success);">
        <span><i class="fa-solid fa-circle-check"></i> Tiền đã cọc:</span>
        <span>- <fmt:formatNumber value="${depositAmount}" pattern="#,###" /> đ</span>
    </div>
</c:if>
```

2. **Tổng cần thanh toán**: Đổi từ "Tổng cộng" thành "Cần thanh toán" và hiển thị `finalAmountToPay`

3. **QR Code SePay**: Cập nhật URL để sử dụng `finalAmountToPay` thay vì `order.totalAmount`
```jsp
src="https://qr.sepay.vn/img?acc=${sepayBankAccount}&bank=${sepayBankName}&amount=${finalAmountToPay.longValue()}&des=${sepayContentPrefix}${order.id}"
```

4. **Số tiền hiển thị trong QR**: Cập nhật `transfer-amount-value` để hiển thị `finalAmountToPay`

## Luồng nghiệp vụ hoàn chỉnh

### Kịch bản: Khách đặt bàn có Pre-order

1. **Khách đặt bàn online**:
   - Tạo Booking với thông tin khách
   - Chọn món Pre-order (PreOrderItem)
   - Thanh toán tiền cọc 10% (depositAmount)
   - Booking status: PENDING → CONFIRMED

2. **Khách đến nhà hàng**:
   - Staff check-in: Booking status → CHECKED_IN
   - Staff assign table: Booking.table = [table]
   - Staff seat customer: Booking status → SEATED, Table status → OCCUPIED

3. **Staff tạo Order**:
   - Gọi `OrderService.createOrder(tableId, staffId)`
   - Hệ thống tự động:
     - Tìm Booking active của bàn
     - Liên kết Order với Booking
     - Copy tất cả PreOrderItem sang OrderDetail
     - Tính tổng tiền Order (bao gồm món Pre-order)

4. **Khách gọi thêm món** (optional):
   - Staff thêm món mới vào Order
   - Tổng tiền được cập nhật

5. **Thanh toán**:
   - Staff confirm order: Order status → SERVED
   - Cashier mở màn hình checkout
   - Hệ thống hiển thị:
     - Tạm tính: [subtotal]
     - Giảm giá: [discount]
     - Tổng cộng: [totalAmount]
     - Tiền đã cọc: -[depositAmount] (màu xanh)
     - **Cần thanh toán: [finalAmountToPay]** (in đậm)
   - QR Code/Thanh toán hiển thị số tiền `finalAmountToPay`
   - Khách thanh toán số tiền còn lại

## Testing

### Test Case 1: Order từ Booking có Pre-order
1. Tạo Booking với 2 món Pre-order (tổng 200,000đ)
2. Thanh toán cọc 20,000đ (10%)
3. Check-in và assign table
4. Tạo Order cho bàn đó
5. **Verify**: Order có 2 OrderDetail từ Pre-order, totalAmount = 200,000đ
6. Gọi thêm 1 món (50,000đ)
7. **Verify**: Order có 3 OrderDetail, totalAmount = 250,000đ
8. Thanh toán
9. **Verify**: 
   - Hiển thị "Tiền đã cọc: -20,000đ"
   - "Cần thanh toán: 230,000đ"
   - QR Code có amount = 230,000

### Test Case 2: Order không từ Booking
1. Khách walk-in (không đặt bàn)
2. Staff tạo Order cho bàn trống
3. **Verify**: Order không có booking, không có PreOrderItem
4. Gọi món bình thường
5. Thanh toán
6. **Verify**: Không hiển thị dòng "Tiền đã cọc", thanh toán full amount

### Test Case 3: Booking không có Pre-order
1. Tạo Booking không chọn món Pre-order
2. Check-in và assign table
3. Tạo Order
4. **Verify**: Order có liên kết với Booking nhưng không có OrderDetail nào
5. Gọi món bình thường
6. Thanh toán
7. **Verify**: Không hiển thị "Tiền đã cọc" (vì depositAmount = 0)

## Lưu ý quan trọng

1. **Giá món**: Khi copy PreOrderItem sang OrderDetail, sử dụng giá hiện tại từ Product (snapshot), không phải giá lúc đặt Pre-order. Điều này đảm bảo giá luôn cập nhật.

2. **ItemStatus**: PreOrderItem được copy với status "PENDING". Staff cần confirm để chuyển sang "ORDERED" và gửi bếp.

3. **Deposit không âm**: Luôn kiểm tra `finalAmountToPay >= 0` để tránh trường hợp tiền cọc lớn hơn tổng bill.

4. **Hibernate lazy loading**: Đảm bảo `booking.getPreOrderItems()` được initialize trong transaction khi cần sử dụng.

5. **Database migration**: Phải chạy migration SQL trước khi deploy code mới.

## Rollback (nếu cần)

Nếu cần rollback các thay đổi:

```sql
-- Remove foreign key and column
ALTER TABLE orders DROP CONSTRAINT IF EXISTS fk_orders_booking;
DROP INDEX IF EXISTS idx_orders_booking_id;
ALTER TABLE orders DROP COLUMN IF EXISTS booking_id;
```

Sau đó revert code về commit trước đó.

## Tác giả
- Ngày: 2026-03-16
- Phiên bản: 1.0
