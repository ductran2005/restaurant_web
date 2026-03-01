package market.restaurant_web.service;

import market.restaurant_web.entity.*;
import market.restaurant_web.dao.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * POSService - Xử lý business logic cho hệ thống POS nhà hàng.
 */
public class POSService {

    private final ProductDAO productDAO = new ProductDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final TableDAO tableDAO = new TableDAO();
    private final AreaDAO areaDAO = new AreaDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final OrderService orderService = new OrderService();

    // ==================== TABLE ====================

    /**
     * Mở bàn: validate + tạo đơn mới.
     * Delegate sang OrderService (kiểm tra trùng đơn).
     */
    public int openTable(int tableId, User createdBy) {
        return orderService.createOrderForTable(tableId, createdBy);
    }

    public List<RestaurantTable> getAvailableTables() {
        return tableDAO.getByStatus("AVAILABLE");
    }

    public List<RestaurantTable> getAllTables() {
        return tableDAO.getAll();
    }

    public List<Area> getAllAreas() {
        return areaDAO.getAll();
    }

    public List<Category> getAllCategories() {
        return categoryDAO.getAll();
    }

    public List<Product> getAvailableProducts() {
        return productDAO.getAvailable();
    }

    // ==================== PRODUCT ====================

    public List<Product> getAllProducts() {
        return productDAO.getAll();
    }

    public Product getProductById(int id) {
        return productDAO.getById(id);
    }

    public void addProduct(Product product) {
        product.setStatus("AVAILABLE");
        productDAO.insert(product);
    }

    public void updateProduct(Product product) {
        productDAO.update(product);
    }

    public void deleteProduct(int id) {
        productDAO.deleteById(id);
    }

    public void softDeleteProduct(int id) {
        productDAO.softDelete(id);
    }

    // ==================== ORDER ====================

    public Order createOrder(RestaurantTable table, User createdBy, String orderType) {
        Order order = new Order();
        order.setTable(table);
        order.setCreatedBy(createdBy);
        order.setOrderType(orderType);
        order.setOpenedAt(LocalDateTime.now());
        order.setSubtotal(BigDecimal.ZERO);
        order.setDiscountAmount(BigDecimal.ZERO);
        order.setTotalAmount(BigDecimal.ZERO);
        order.setStatus("OPEN");
        orderDAO.insert(order);
        return order;
    }

    /**
     * Thêm món vào đơn. Nếu món đã có → tăng SL (addOrIncrease).
     * Tự động cập nhật subtotal/total.
     */
    public void addItemToOrder(int orderId, int productId, int quantity) {
        // Dùng addOrIncrease: nếu món đã có trong đơn thì tăng SL
        orderDetailDAO.addOrIncrease(orderId, productId, quantity);

        // Tính lại subtotal & total từ tất cả chi tiết
        recalculateOrderTotal(orderId);
    }

    /**
     * Tính lại subtotal và totalAmount dựa trên tất cả order details.
     */
    private void recalculateOrderTotal(int orderId) {
        Order order = orderDAO.getById(orderId);
        if (order == null)
            return;

        List<OrderDetail> details = orderDetailDAO.getByOrderId(orderId);
        BigDecimal subtotal = BigDecimal.ZERO;
        for (OrderDetail d : details) {
            if (d.getUnitPrice() != null) {
                subtotal = subtotal.add(d.getUnitPrice().multiply(BigDecimal.valueOf(d.getQuantity())));
            }
        }
        order.setSubtotal(subtotal);
        BigDecimal discount = order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO;
        order.setTotalAmount(subtotal.subtract(discount));
        orderDAO.update(order);
    }

    /**
     * Xác nhận đơn hàng (OPEN → SERVED).
     */
    public void confirmOrder(int orderId) {
        PaymentService paymentService = new PaymentService();
        paymentService.confirm(orderId);
    }

    public List<OrderDetail> getOrderDetails(int orderId) {
        return orderDetailDAO.getByOrderId(orderId);
    }

    public Order getOrderById(int orderId) {
        return orderDAO.getById(orderId);
    }

    // ==================== CHECKOUT ====================

    public Payment checkout(int orderId, String paymentMethod, int cashierId) {
        Order order = orderDAO.getById(orderId);
        if (order == null || !"OPEN".equals(order.getStatus())) {
            return null;
        }

        // Tạo thanh toán
        Payment payment = new Payment();
        payment.setOrderId(orderId);
        payment.setCashierId(cashierId);
        payment.setMethod(paymentMethod);
        payment.setAmountPaid(order.getTotalAmount());
        payment.setDiscountAmount(order.getDiscountAmount());
        payment.setFinalAmount(order.getTotalAmount());
        payment.setPaidAt(LocalDateTime.now());
        payment.setPaymentStatus("SUCCESS");
        paymentDAO.insert(payment);

        // Cập nhật trạng thái đơn hàng
        order.setStatus("PAID");
        order.setClosedAt(LocalDateTime.now());
        orderDAO.update(order);

        // Giải phóng bàn
        releaseTable(order.getTable());

        return payment;
    }

    public void cancelOrder(int orderId) {
        Order order = orderDAO.getById(orderId);
        if (order != null && "OPEN".equals(order.getStatus())) {
            order.setStatus("CANCELLED");
            order.setClosedAt(LocalDateTime.now());
            orderDAO.update(order);

            // Giải phóng bàn
            releaseTable(order.getTable());
        }
    }

    /**
     * Giải phóng bàn - đổi trạng thái về AVAILABLE.
     */
    private void releaseTable(RestaurantTable table) {
        if (table != null) {
            table.setStatus("AVAILABLE");
            tableDAO.update(table);
        }
    }

    // ==================== SEARCH ====================

    public List<Product> searchProducts(String keyword) {
        return productDAO.searchByName(keyword);
    }

    public List<Order> getOpenOrders() {
        return orderDAO.getByStatus("OPEN");
    }

    public List<Order> getPaidOrders() {
        return orderDAO.getByStatus("PAID");
    }
}
