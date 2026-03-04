# CHANGELOG - Frontend (JSP) Sync với Backend

> **Build vẫn OK:** 53 files, 0 errors sau khi sửa FE.

---

## [Giữ nguyên] - Không thay đổi

| File | Lý do |
|---|---|
| `index.jsp` | Landing redirect - giữ nguyên theo yêu cầu |
| `customer/landing.jsp` | Trang chủ - nội dung tĩnh, giữ nguyên |
| `customer/about.jsp` | Trang giới thiệu - nội dung tĩnh |
| `customer/contact.jsp` | Trang liên hệ - nội dung tĩnh |
| `customer/_footer.jsp` | Footer partial - nội dung tĩnh |
| `admin/tables-areas.jsp` | Đã dùng đúng field names (areaName, tableName, capacity) |
| `auth/login.jsp` | Không có field thay đổi |
| `auth/register.jsp` | Không có field thay đổi |
| `auth/access-denied.jsp` | Trang lỗi tĩnh |
| `auth/forgot-password.jsp` | Trang tĩnh |
| `error/404.jsp` | Trang lỗi tĩnh |
| `error/500.jsp` | Trang lỗi tĩnh |
| `components/C-ConfirmModal.jsp` | Component chung |
| `components/C-DrawerRight.jsp` | Component chung |
| `components/C-MoneyBreakdownCard.jsp` | Component chung |
| `components/C-StatusBadge.jsp` | Component chung |
| `components/layout/L-AdminShell.jsp` | Layout chung |
| `components/layout/L-CustomerShell.jsp` | Layout chung |

---

## [Đã sửa] - JSP files đã đồng bộ

### 1. `admin/_sidebar.jsp` (shared sidebar)
| Trước | Sau | Lý do |
|---|---|---|
| `user.role == 'ADMIN'` | `user.role.name == 'ADMIN'` | Role là object, cần .name |
| Link `/admin/rbac` | **Commented out** | Controller đã xóa (no permissions table) |
| Link `/admin/config` | **Commented out** | Controller đã xóa (no system_configs table) |
| Link `/staff/booking` | **Commented out** | Controller đã xóa (no bookings table) |
| `${user.role}` (footer) | `${user.role.name}` | Role là object |

### 2. `admin/dashboard.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| Sidebar links rbac/config/reports | **Removed** | Controllers đã xóa |
| Sidebar link booking | **Removed** | Controller đã xóa |
| `${activeMenuItems}` | `${activeProducts}` | Controller set `activeProducts` |
| `${totalBookings}` | `${totalBookings} (chưa hỗ trợ)` | Luôn 0, hiển thị note |

### 3. `admin/categories.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| Cột "Mô tả" + `${cat.description}` | **Removed** | DB categories không có cột description |
| `${cat.itemCount}` | `${cat.products.size()}` | Dùng size() của collection |
| `${cat.isActive}` | `${cat.status == 'ACTIVE'}` | Status là NVARCHAR không phải Boolean |

### 4. `admin/menu-items.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| `${menuItems}` | `${products}` | Controller set `products` |
| `${item.imageUrl}` | **Removed** | DB products không có cột image_url |
| `${item.itemName}` | `${item.productName}` | DB column = product_name |
| `${item.isSoldOut}` / `${item.isActive}` | `${item.status}` | Status: AVAILABLE/UNAVAILABLE |
| `${item.quantity}` | **Removed** | Không có trong products, xem inventory |
| Cột "Hình" | **Removed** | Không có image_url |
| — | Cột "Giá vốn" (`${item.costPrice}`) | DB có cột cost_price |

### 5. `cashier/checkout.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| `${d.menuItem.itemName}` | `${d.product.productName}` | OrderDetail → Product |
| `${d.menuItem.price}` | `${d.unitPrice}` | DB column = unit_price |
| `${d.subtotal}` | `${d.lineTotal}` | DB computed column = line_total |
| `${invoice.subtotal}` | `${order.subtotal}` | Không có invoices table |
| `${invoice.vatAmount}` | **Removed** | DB không có VAT |
| `${invoice.serviceFee}` | **Removed** | DB không có service fee |
| `${invoice.totalAmount}` | `${order.totalAmount}` | Trực tiếp từ order |
| Payment values: Tiền mặt/Chuyển khoản/QR | CASH/CARD/TRANSFER | DB CHECK constraint |
| Filter `orderDetails` hiện tất cả | Filter `itemStatus == 'ORDERED'` | Bỏ qua items CANCELLED |

### 6. `cashier/orders-list.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| `${invoices}` forEach | `${orders}` / `${paidOrders}` | Không có invoices table |
| `${inv.invoiceId}` | `${o.id}` | Dùng Order ID |
| Cột VAT/Phí DV | **Removed** | Không có trong DB |
| `${inv.status}` UNPAID/PAID | Tab "Đang hoạt động" / "Đã thanh toán" | Order status: OPEN/SERVED/PAID |
| Tab đơn | Split thành 2 tabs | Active orders vs Paid orders |

### 7. `staff/order-editor.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| `${orders}` | `${activeOrders}` | Controller set `activeOrders` |
| `${o.orderId}` | `${o.id}` | Order entity field name |
| `${o.orderTime}` | `${o.openedAt}` | DB column = opened_at |

### 8. `staff/table-map.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| Sidebar link booking | **Removed** | Controller đã xóa |
| Legend: Trống/Phục vụ/Đã đặt/Cần dọn | Trống/Đang dùng | DB chỉ có 2 status |
| Status dropdown: 5 options | 2 options: AVAILABLE/IN_USE | DB CHECK constraint |

### 9. `customer/public-menu.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| `${menuItems}` | `${products}` | Controller set `products` |
| `${item.itemName}` | `${item.productName}` | DB column = product_name |
| `${item.imageUrl}` | Placeholder image | DB không có image_url |
| `${item.isSoldOut}` | `${item.status == 'UNAVAILABLE'}` | Status string thay boolean |

### 10. `customer/_navbar.jsp`
| Trước | Sau | Lý do |
|---|---|---|
| Link `/booking/create` | **Commented out** | Controller đã xóa |
| Link `/booking/status` | **Commented out** | Controller đã xóa |
| Link `/pre-order` | **Commented out** | Controller đã xóa |
| Link `/customer/home` | **Removed** | Controller đã xóa |

---

## [KHÔNG THỂ DÙNG] - JSP orphaned (controller đã xóa)

> ⚠️ **Các JSP sau đây KHÔNG CÒN controller xử lý**, sẽ trả về 404 nếu truy cập:

| JSP File | URL cũ | Controller đã xóa | Lý do |
|---|---|---|---|
| `admin/rbac.jsp` | `/admin/rbac` | `RbacController` | DB không có bảng permissions/role_permissions |
| `admin/system-config.jsp` | `/admin/config` | `SystemConfigController` | DB không có bảng system_configs |
| `staff/booking-search.jsp` | `/staff/booking` | `BookingSearchController` | DB không có bảng bookings |
| `customer/booking-status.jsp` | `/booking/status` | `BookingStatusController` | DB không có bảng bookings |
| `customer/create-booking.jsp` | `/booking/create` | `CreateBookingController` | DB không có bảng bookings |
| `customer/pre-order.jsp` | `/pre-order` | `PreOrderController` | DB không có bảng booking_items |
| `customer/customer-home.jsp` | `/customer/home` | `CustomerHomeController` | Phụ thuộc BookingService đã xóa |

> **Khuyến nghị:** Có thể xóa 7 files JSP trên vì chúng không bao giờ được render. Tạm giữ lại để không mất code UI (có thể dùng lại khi thêm feature).

---

## Landing page (landing.jsp)

> ⚠️ **GIỮ NGUYÊN** theo yêu cầu. Tuy nhiên lưu ý:
> - Các link `/booking/create`, `/booking/status`, `/pre-order` trong landing.jsp sẽ trả 404
> - Đây là links tĩnh trong HTML, không gây lỗi build nhưng user click sẽ thấy 404
> - Khuyến nghị: thay bằng `/menu` hoặc remove khi có thời gian

---

## Tóm tắt

| Loại | Số |
|---|---|
| JSP giữ nguyên | 18 |
| JSP đã sửa | 10 |
| JSP orphaned (không dùng được) | 7 |
| **Tổng JSP** | **34** |
