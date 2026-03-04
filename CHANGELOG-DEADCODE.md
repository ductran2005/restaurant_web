# CHANGELOG — Dead Code Removal & Optimization

> **Build:** `mvn clean compile` → **BUILD SUCCESS** (51 Java files, 0 errors, 0 new warnings)
> **Date:** 2026-03-04

---

## Call Graph Analysis

```
Entrypoints (18 @WebServlet)
├── /                 → LandingController → landing.jsp
├── /menu             → PublicMenuController → ProductService + CategoryService → public-menu.jsp
├── /about            → AboutController → about.jsp
├── /contact          → ContactController → ValidationUtil → contact.jsp
├── /login            → LoginController → AuthService → PasswordUtil → login.jsp
├── /logout           → LogoutController
├── /register         → RegisterController → AuthService → ValidationUtil → register.jsp
├── /forgot-password  → ForgotPasswordController → forgot-password.jsp
├── /access-denied    → AccessDeniedController → access-denied.jsp
├── /admin            → DashboardController → OrderService + PaymentService + ProductService → dashboard.jsp
├── /admin/categories → CategoriesController → CategoryService → ValidationUtil → categories.jsp
├── /admin/menu       → MenuItemsController → ProductService + CategoryService → ValidationUtil → menu-items.jsp
├── /admin/tables     → TablesAreasController → TableService → ValidationUtil → tables-areas.jsp
├── /staff            → TableMapController → TableService → table-map.jsp
├── /staff/orders     → OrderEditorController → OrderService + ProductService + CategoryService → ValidationUtil → order-editor.jsp
├── /cashier          → OrdersListController → OrderService → orders-list.jsp
├── /cashier/checkout → CheckoutController → OrderService + PaymentService → checkout.jsp
└── /assets/*         → StaticResourceController (serves CSS/JS/images)

Filters (3, via web.xml)
├── EncodingFilter  /* → Sets UTF-8
├── AuthFilter      /* → Session check
└── RbacFilter      /* → Role-based access

Reachable Entities (via Hibernate + call graph)
├── Role         → RoleDao   → AuthService
├── User         → UserDao   → AuthService
├── Area         → AreaDao   → TableService
├── DiningTable  → TableDao  → TableService
├── Category     → CategoryDao → CategoryService
├── Product      → ProductDao  → ProductService
├── Order        → OrderDao  → OrderService
├── OrderDetail  → (embedded in Order) → OrderService
└── Payment      → PaymentDao → PaymentService

Unreachable Entities (mapped in Hibernate but NO DAO/Service uses them)
├── Inventory       → No DAO, No Service, No Controller
├── InventoryLog    → No DAO, No Service, No Controller
└── UserSession     → No DAO, No Service, No Controller
```

---

## [Removed] — Files Deleted

### Java Utils (dead — 0 references)
| File | Lý do |
|---|---|
| `util/DateTimeUtil.java` | 0 references ngoài chính nó. Không import từ bất kỳ Service/Controller nào |
| `util/MoneyUtil.java` | 0 references ngoài chính nó. Đã fix warning `deprecated API` luôn |

### Orphaned JSP Views (no controller forwards to them)
| File | Lý do |
|---|---|
| `admin/rbac.jsp` | Controller `RbacController` đã xóa ở session trước (no permissions table) |
| `admin/system-config.jsp` | Controller `SystemConfigController` đã xóa (no system_configs table) |
| `staff/booking-search.jsp` | Controller `BookingSearchController` đã xóa (no bookings table) |
| `customer/booking-status.jsp` | Controller `BookingStatusController` đã xóa (no bookings table) |
| `customer/create-booking.jsp` | Controller `CreateBookingController` đã xóa (no bookings table) |
| `customer/pre-order.jsp` | Controller `PreOrderController` đã xóa (no booking_items table) |
| `customer/customer-home.jsp` | Controller `CustomerHomeController` đã xóa (depended on BookingService) |

### Orphaned Component JSPs (only self-reference, no page includes them)
| File | Lý do |
|---|---|
| `components/C-ConfirmModal.jsp` | grep: 0 includes from any page JSP |
| `components/C-DrawerRight.jsp` | grep: 0 includes from any page JSP |
| `components/C-MoneyBreakdownCard.jsp` | grep: 0 includes from any page JSP |
| `components/C-StatusBadge.jsp` | grep: 0 includes from any page JSP |
| `components/layout/L-AdminShell.jsp` | grep: 0 includes from any page JSP |
| `components/layout/L-CustomerShell.jsp` | grep: 0 includes from any page JSP |
| `components/` (directory) | Empty after deleting above files |

### Static Resources (dead)
| File | Lý do |
|---|---|
| `assets/img/hero.png` | 0 references in any JSP/HTML/CSS |
| `test-css.html` | Test file, not routed, not part of app |

### Maven Dependencies (unused — 0 imports in codebase)
| Dependency | Size Impact | Lý do |
|---|---|---|
| `com.google.code.gson:gson:2.10.1` | ~250KB | 0 imports of `com.google.gson` anywhere |
| `org.apache.poi:poi-ooxml:5.2.5` | ~15MB | 0 imports of `org.apache.poi` anywhere |

---

## [Changed] — Files Modified

| File | Thay đổi | Lý do |
|---|---|---|
| `OrderService.java` | Removed `import java.time.LocalDateTime` | Unused import (IDE lint) |
| `PublicMenuController.java` | `@WebServlet({"/menu","/public-menu"})` → `@WebServlet("/menu")` | `/public-menu` alias unused, no link points to it |
| `pom.xml` | Removed 2 dependencies (Gson + POI) | 0 usage in codebase |
| `web.xml` | Removed `*.jspf` property group | No .jspf files exist |

---

## [Candidate] — Đề xuất xóa (cần confirm)

> ⚠️ Các items này KO XÓA vì có lý do kỹ thuật, nhưng hiện tại chưa có code sử dụng:

| File | Lý do giữ | Có thể xóa khi |
|---|---|---|
| `entity/Inventory.java` | Mapped trong `hibernate.cfg.xml`, DB table `inventory` tồn tại. Xóa sẽ gây Hibernate validate error | Khi có InventoryService/InventoryDao |
| `entity/InventoryLog.java` | Mapped trong `hibernate.cfg.xml`, DB table `inventory_log` tồn tại. Xóa sẽ gây validate error | Khi có InventoryLogService |
| `entity/UserSession.java` | Mapped trong `hibernate.cfg.xml`, DB table `user_sessions` tồn tại. Xóa sẽ gây validate error | Khi implement session tracking feature |
| `auth/ForgotPasswordController.java` | Có `@WebServlet("/forgot-password")` đang serve. doPost chỉ hiện message demo. Login page có link tới | Khi implement email reset thật |
| `StaticResourceController.java` | Có `@WebServlet("/assets/*")` đang serve CSS/JS/images. Một số app server (non-Tomcat) cần nó | Khi dùng Tomcat DefaultServlet thay thế |

---

## Summary Files

### FILES REMOVED (17 files + 1 directory)
```
src/main/java/market/restaurant_web/util/DateTimeUtil.java
src/main/java/market/restaurant_web/util/MoneyUtil.java
src/main/webapp/WEB-INF/views/admin/rbac.jsp
src/main/webapp/WEB-INF/views/admin/system-config.jsp
src/main/webapp/WEB-INF/views/staff/booking-search.jsp
src/main/webapp/WEB-INF/views/customer/booking-status.jsp
src/main/webapp/WEB-INF/views/customer/create-booking.jsp
src/main/webapp/WEB-INF/views/customer/pre-order.jsp
src/main/webapp/WEB-INF/views/customer/customer-home.jsp
src/main/webapp/WEB-INF/views/components/C-ConfirmModal.jsp
src/main/webapp/WEB-INF/views/components/C-DrawerRight.jsp
src/main/webapp/WEB-INF/views/components/C-MoneyBreakdownCard.jsp
src/main/webapp/WEB-INF/views/components/C-StatusBadge.jsp
src/main/webapp/WEB-INF/views/components/layout/L-AdminShell.jsp
src/main/webapp/WEB-INF/views/components/layout/L-CustomerShell.jsp
src/main/webapp/WEB-INF/views/components/     (empty dir)
src/main/webapp/assets/img/hero.png
src/main/webapp/test-css.html
```

### FILES MODIFIED (4 files)
```
src/main/java/market/restaurant_web/service/OrderService.java
src/main/java/market/restaurant_web/controller/customer/PublicMenuController.java
pom.xml
src/main/webapp/WEB-INF/web.xml
```

---

## Verify Checklist

### ✅ Build
```
mvn clean compile → BUILD SUCCESS (51 files, 0 errors)
```

### Smoke Test Endpoints
| URL | Role | Expected |
|---|---|---|
| `/` | Public | Landing page (customer/landing.jsp) |
| `/menu` | Public | Public menu with products |
| `/about` | Public | About page |
| `/contact` | Public | Contact form |
| `/login` | Public | Login form |
| `/register` | Public | Registration form |
| `/forgot-password` | Public | Forgot password form (demo) |
| `/admin` | ADMIN | Dashboard with KPIs + chart |
| `/admin/categories` | ADMIN | Category CRUD |
| `/admin/menu` | ADMIN | Product CRUD |
| `/admin/tables` | ADMIN | Table/Area CRUD |
| `/staff` | STAFF/ADMIN | Table map |
| `/staff/orders` | STAFF/ADMIN | Order editor |
| `/cashier` | CASHIER/ADMIN | Orders list (active/paid tabs) |
| `/cashier/checkout?orderId=X` | CASHIER/ADMIN | Checkout page |
| `/access-denied` | Any | 403 page |

### File Count After Cleanup
| Type | Before | After | Removed |
|---|---|---|---|
| Java files | 53 | 51 | 2 |
| JSP files | 35 | 22 | 13 |
| Static HTML | 1 | 0 | 1 |
| Images | 6 | 5 | 1 |
| Maven deps | 7 | 5 | 2 |
| **Total project files removed** | | | **17** |

### WAR Size Estimate
- Removed ~**15.5MB** of unnecessary dependencies (POI ~15MB, Gson ~250KB)
- Removed 13 JSP files + 2 Java utils + 1 HTML + 1 image
