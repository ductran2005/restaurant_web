# CHANGELOG - Backend Sync with DB (Restaurant_Ipos)

> [!IMPORTANT]
> Tổng kết: Đã đồng bộ 100% backend với database schema `Restaurant_Ipos`. Build thành công (53 files, 0 errors).

---

## [Removed] - Files/Entities/Features đã XÓA

### Entities (không có table tương ứng trong DB)
| File đã xóa | Lý do |
|---|---|
| `entity/Booking.java` | DB không có bảng `bookings` |
| `entity/BookingItem.java` | DB không có bảng `booking_items` |
| `entity/Invoice.java` | DB không có bảng `invoices` |
| `entity/Permission.java` | DB không có bảng `permissions` |
| `entity/RolePermission.java` | DB không có bảng `role_permissions` |
| `entity/SystemConfig.java` | DB không có bảng `system_configs` |
| `entity/MenuItem.java` | DB tên bảng là `products` → thay bằng `Product.java` |
| `entity/OrderItem.java` | DB tên bảng là `order_details` → thay bằng `OrderDetail.java` |

### DAOs
| File đã xóa | Lý do |
|---|---|
| `dao/BookingDao.java` | Entity Booking đã xóa |
| `dao/InvoiceDao.java` | Entity Invoice đã xóa |
| `dao/PermissionDao.java` | Entity Permission đã xóa |
| `dao/SystemConfigDao.java` | Entity SystemConfig đã xóa |
| `dao/MenuItemDao.java` | Thay bằng `ProductDao.java` |

### Services
| File đã xóa | Lý do |
|---|---|
| `service/BookingService.java` | Entity Booking đã xóa |
| `service/InvoiceService.java` | Entity Invoice đã xóa → thay bằng `PaymentService.java` |
| `service/RbacService.java` | Entity Permission/RolePermission đã xóa |
| `service/SystemConfigService.java` | Entity SystemConfig đã xóa |
| `service/MenuItemService.java` | Thay bằng `ProductService.java` |

### Controllers
| File đã xóa | Lý do |
|---|---|
| `controller/admin/RbacController.java` | Không có permissions/role_permissions table |
| `controller/admin/SystemConfigController.java` | Không có system_configs table |
| `controller/staff/BookingSearchController.java` | Không có bookings table |
| `controller/customer/CreateBookingController.java` | Không có bookings table |
| `controller/customer/BookingStatusController.java` | Không có bookings table |
| `controller/customer/PreOrderController.java` | Không có booking_items table |
| `controller/customer/CustomerHomeController.java` | Phụ thuộc BookingService đã xóa |

---

## [Changed] - Files đã SỬA

### Entity Changes

#### `Role.java`
| Trước | Sau | Lý do |
|---|---|---|
| `@Column(name = "id")` | `@Column(name = "role_id")` | DB PK = role_id |
| `name` field | `roleName` + `getName()` alias | DB column = role_name |
| `created_at` field | **Removed** | DB không có cột này |
| `permissions` M:M | **Removed** | DB không có bảng permissions |

#### `User.java`
| Trước | Sau | Lý do |
|---|---|---|
| `@Column(name = "id")` | `@Column(name = "user_id")` | DB PK = user_id |
| `isActive` (Boolean) | `status` (String: ACTIVE/INACTIVE) | DB dùng NVARCHAR |
| `updated_at` | **Removed** | DB không có cột này |
| — | `phone` (VARCHAR 20) | DB có cột phone |
| — | `email` (VARCHAR 120, unique) | DB có cột email |
| — | `failedLoginCount` (INT) | DB có cột failed_login_count |
| — | `lastFailedLoginAt` (DATETIME) | DB có cột last_failed_login_at |
| — | `lockedUntil` (DATETIME) | DB có cột locked_until |

#### `Area.java`
| Trước | Sau | Lý do |
|---|---|---|
| PK `id` | PK `area_id` | DB PK = area_id |
| `name` | `areaName` + alias | DB column = area_name |
| `displayOrder` | **Removed** | DB không có cột này |
| — | `description` | DB có cột description |

#### `DiningTable.java` → maps to `tables`
| Trước | Sau | Lý do |
|---|---|---|
| PK `id` | PK `table_id` | DB PK = table_id |
| `code` | `tableName` + `getCode()` alias | DB column = table_name |
| `seats` | `capacity` + `getSeats()` alias | DB column = capacity |
| Status: AVAILABLE/SERVING/CLEANING/RESERVED/DISABLED | Status: AVAILABLE/IN_USE | DB CHECK constraint |
| `bookings` 1:M | **Removed** | DB không có bookings |

#### `Category.java`
| Trước | Sau | Lý do |
|---|---|---|
| PK `id` | PK `category_id` | DB PK = category_id |
| `name` | `categoryName` + alias | DB column = category_name |
| `isActive` (Boolean) | `status` (ACTIVE/INACTIVE) | DB dùng NVARCHAR |
| `description` | **Removed** | DB không có cột này |
| `menuItems` 1:M | `products` 1:M | Bảng products thay menu_items |

#### `Order.java`
| Trước | Sau | Lý do |
|---|---|---|
| PK `id` | PK `order_id` | DB PK = order_id |
| `createdAt` | `openedAt` | DB column = opened_at |
| — | `closedAt` | DB có cột closed_at |
| — | `orderType` (DINE_IN/TAKE_AWAY/DELIVERY) | DB có cột order_type |
| — | `subtotal`, `discountAmount`, `totalAmount` | DB có các cột này |
| — | `note` | DB có cột note |
| Status: OPEN/PROCESSING/CLOSED | Status: OPEN/SERVED/CANCELLED/PAID | DB CHECK constraint |
| `booking` FK | **Removed** | DB không có bookings |
| `invoice` 1:1 | **Removed** | DB không có invoices |
| `orderItems` 1:M | `orderDetails` 1:M | Bảng order_details thay order_items |

#### `Payment.java`
| Trước | Sau | Lý do |
|---|---|---|
| PK `id` | PK `payment_id` | DB PK = payment_id |
| FK `invoice` | FK `order` | DB FK = order_id |
| `createdBy` FK | `cashier` FK | DB FK = cashier_id |
| `createdAt` | `paidAt` | DB column = paid_at |
| `amount` | `amountPaid` | DB column = amount_paid |
| `status` | `paymentStatus` | DB column = payment_status |
| `type` (CHARGE/REFUND) | **Removed** | DB không có cột này |
| — | `discountAmount` | DB có cột discount_amount |
| — | `finalAmount` | DB có cột final_amount |
| Method: CASH/CARD/BANK/EWALLET | Method: CASH/CARD/TRANSFER | DB CHECK constraint |

### New Entity Files (bảng có trong DB nhưng chưa có entity)
| File mới | Maps to DB table |
|---|---|
| `entity/Product.java` | `products` |
| `entity/OrderDetail.java` | `order_details` |
| `entity/Inventory.java` | `inventory` |
| `entity/InventoryLog.java` | `inventory_logs` |
| `entity/UserSession.java` | `user_sessions` |

### Hibernate Config (`hibernate.cfg.xml`)
- `hbm2ddl.auto`: `update` → `validate` (không tự sửa DB)
- Removed mappings: Permission, RolePermission, MenuItem, OrderItem, Booking, BookingItem, Invoice, SystemConfig
- Added mappings: Product, OrderDetail, Inventory, InventoryLog, UserSession

### Filter Changes

#### `AuthFilter.java`
- Removed `/booking/create`, `/booking/status` from public pages (no bookings table)
- Removed `/customer/home` from requiresAuth
- Changed `user.getIsActive()` → `user.isActive()` (checks status string)
- Added `/about`, `/contact` as public pages

#### `RbacFilter.java`
- **Complete rewrite**: permission-based → role-based
- No more permission codes (no permissions table)
- URL → allowed roles: `/admin`→ADMIN, `/staff`→ADMIN+STAFF, `/cashier`→ADMIN+CASHIER

### Service Changes

| Service | Key Changes |
|---|---|
| `AuthService` | Removed `getPermissions()`. Login checks `isActive()` + `lockedUntil`. Register sets `status="ACTIVE"` |
| `CategoryService` | Uses `status` string instead of `isActive` boolean |
| `TableService` | Removed `disableTable()` (no DISABLED status). Status: AVAILABLE/IN_USE only |
| `OrderService` | Uses Product/OrderDetail. Removed booking logic. Status: OPEN/SERVED/CANCELLED/PAID. `createOrder()` no longer takes bookingId |
| `PaymentService` **NEW** | Replaces InvoiceService. Direct order→payment flow. Checkout creates payment + marks order PAID + frees table |
| `ProductService` **NEW** | Replaces MenuItemService. Uses AVAILABLE/UNAVAILABLE status |

### Controller Changes

| Controller | Key Changes |
|---|---|
| `LoginController` | Removed `getPermissions()`, sets empty permissions set |
| `RegisterController` | Removed `getPermissions()`, sets empty permissions set |
| `DashboardController` | Uses PaymentService instead of InvoiceService, ProductService instead of MenuItemService, removed BookingService |
| `CategoriesController` | Removed `setDescription()`, `setIsActive()` → `setStatus()` |
| `MenuItemsController` | Uses Product/ProductService. Removed imageUrl, added costPrice, toggleStatus |
| `TablesAreasController` | Removed `displayOrder`, removed `disableTable`, added `description` for area |
| `CheckoutController` | Uses PaymentService instead of InvoiceService. Removed refund/void |
| `OrdersListController` | Removed InvoiceService. Tab "invoices"→"paid" showing PAID orders |
| `OrderEditorController` | Uses ProductService. Removed BookingService. Params: productId, orderDetailId |
| `PublicMenuController` | Uses ProductService instead of MenuItemService |

---

## [Notes] - Ảnh hưởng UI/JSP

> [!WARNING]
> Các JSP views sau đây có thể cần cập nhật để khớp với backend mới:

1. **admin/dashboard.jsp** - `activeMenuItems` → `activeProducts`, không còn `totalBookings` (set 0)
2. **admin/categories.jsp** - Không còn field `description`, `isActive` → checkbox maps to status
3. **admin/menu-items.jsp** - `menuItems` → `products`, không còn `imageUrl`, `isSoldOut` → `status`, thêm `costPrice`
4. **admin/tables-areas.jsp** - Không còn `displayOrder` cho area, status chỉ AVAILABLE/IN_USE
5. **admin/rbac.jsp** - Controller đã xóa → JSP orphaned, cần xóa hoặc giữ placeholder
6. **admin/system-config.jsp** - Controller đã xóa → JSP orphaned
7. **cashier/checkout.jsp** - `invoice` → `payment`, field names thay đổi
8. **cashier/orders-list.jsp** - Tab "invoices" → "paid", `closedOrders` → removed
9. **staff/order-editor.jsp** - `menuItems` → `products`, `bookings` removed, `menuItemId` → `productId`, `orderItemId` → `orderDetailId`
10. **staff/booking-search.jsp** - Controller đã xóa → JSP orphaned
11. **customer/create-booking.jsp** - Controller đã xóa → JSP orphaned
12. **customer/booking-status.jsp** - Controller đã xóa → JSP orphaned
13. **customer/pre-order.jsp** - Controller đã xóa → JSP orphaned
14. **customer/public-menu.jsp** - `menuItems` → `products`, không còn `imageUrl`

---

## Build Result

```
[INFO] Compiling 53 source files with javac [debug target 17] to target\classes
[INFO] BUILD SUCCESS
[INFO] Total time:  3.292 s
```

---

## Files Changed (full list)

### Modified (overwritten)
```
src/main/java/market/restaurant_web/entity/Role.java
src/main/java/market/restaurant_web/entity/User.java
src/main/java/market/restaurant_web/entity/Area.java
src/main/java/market/restaurant_web/entity/DiningTable.java
src/main/java/market/restaurant_web/entity/Category.java
src/main/java/market/restaurant_web/entity/Order.java
src/main/java/market/restaurant_web/entity/Payment.java
src/main/java/market/restaurant_web/dao/RoleDao.java
src/main/java/market/restaurant_web/dao/UserDao.java
src/main/java/market/restaurant_web/dao/AreaDao.java
src/main/java/market/restaurant_web/dao/TableDao.java
src/main/java/market/restaurant_web/dao/CategoryDao.java
src/main/java/market/restaurant_web/dao/OrderDao.java
src/main/java/market/restaurant_web/dao/PaymentDao.java
src/main/java/market/restaurant_web/service/AuthService.java
src/main/java/market/restaurant_web/service/CategoryService.java
src/main/java/market/restaurant_web/service/OrderService.java
src/main/java/market/restaurant_web/service/TableService.java
src/main/java/market/restaurant_web/controller/auth/LoginController.java
src/main/java/market/restaurant_web/controller/auth/RegisterController.java
src/main/java/market/restaurant_web/controller/admin/DashboardController.java
src/main/java/market/restaurant_web/controller/admin/CategoriesController.java
src/main/java/market/restaurant_web/controller/admin/MenuItemsController.java
src/main/java/market/restaurant_web/controller/admin/TablesAreasController.java
src/main/java/market/restaurant_web/controller/cashier/CheckoutController.java
src/main/java/market/restaurant_web/controller/cashier/OrdersListController.java
src/main/java/market/restaurant_web/controller/staff/OrderEditorController.java
src/main/java/market/restaurant_web/controller/customer/PublicMenuController.java
src/main/java/market/restaurant_web/filter/AuthFilter.java
src/main/java/market/restaurant_web/filter/RbacFilter.java
src/main/resources/hibernate.cfg.xml
```

### Created (new files)
```
src/main/java/market/restaurant_web/entity/Product.java
src/main/java/market/restaurant_web/entity/OrderDetail.java
src/main/java/market/restaurant_web/entity/Inventory.java
src/main/java/market/restaurant_web/entity/InventoryLog.java
src/main/java/market/restaurant_web/entity/UserSession.java
src/main/java/market/restaurant_web/dao/ProductDao.java
src/main/java/market/restaurant_web/service/ProductService.java
src/main/java/market/restaurant_web/service/PaymentService.java
```

### Deleted
```
src/main/java/market/restaurant_web/entity/Booking.java
src/main/java/market/restaurant_web/entity/BookingItem.java
src/main/java/market/restaurant_web/entity/Invoice.java
src/main/java/market/restaurant_web/entity/Permission.java
src/main/java/market/restaurant_web/entity/RolePermission.java
src/main/java/market/restaurant_web/entity/SystemConfig.java
src/main/java/market/restaurant_web/entity/MenuItem.java
src/main/java/market/restaurant_web/entity/OrderItem.java
src/main/java/market/restaurant_web/dao/BookingDao.java
src/main/java/market/restaurant_web/dao/InvoiceDao.java
src/main/java/market/restaurant_web/dao/PermissionDao.java
src/main/java/market/restaurant_web/dao/SystemConfigDao.java
src/main/java/market/restaurant_web/dao/MenuItemDao.java
src/main/java/market/restaurant_web/service/BookingService.java
src/main/java/market/restaurant_web/service/InvoiceService.java
src/main/java/market/restaurant_web/service/RbacService.java
src/main/java/market/restaurant_web/service/SystemConfigService.java
src/main/java/market/restaurant_web/service/MenuItemService.java
src/main/java/market/restaurant_web/controller/admin/RbacController.java
src/main/java/market/restaurant_web/controller/admin/SystemConfigController.java
src/main/java/market/restaurant_web/controller/staff/BookingSearchController.java
src/main/java/market/restaurant_web/controller/customer/CreateBookingController.java
src/main/java/market/restaurant_web/controller/customer/BookingStatusController.java
src/main/java/market/restaurant_web/controller/customer/PreOrderController.java
src/main/java/market/restaurant_web/controller/customer/CustomerHomeController.java
```

---

## Test Steps

### 1. Build
```powershell
& "C:\Program Files\Apache NetBeans\java\maven\bin\mvn.cmd" clean compile
# Expected: BUILD SUCCESS
```

### 2. Deploy to Tomcat (via NetBeans)
- Open project in NetBeans
- Right-click → Clean and Build
- Right-click → Run (deploys to Tomcat 10+)

### 3. Test Login
- Navigate to `http://localhost:8080/restaurant_web/login`
- Login with existing user in `users` table
- Should redirect to role-based home page

### 4. Test Admin Dashboard
- Login as ADMIN
- Navigate to `/admin` → should show KPIs and chart data
- Navigate to `/admin/categories` → CRUD categories
- Navigate to `/admin/menu` → CRUD products
- Navigate to `/admin/tables` → manage areas and tables

### 5. Test Staff Flow
- Login as STAFF → `/staff` table map
- Create order → add products → verify order totals

### 6. Test Cashier
- Login as CASHIER → `/cashier` order list
- Checkout order → create payment → verify table returns to AVAILABLE
