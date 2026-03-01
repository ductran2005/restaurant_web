package market.restaurant_web.service;

import market.restaurant_web.entity.*;
import market.restaurant_web.dao.*;

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

    // ==================== PRODUCT ====================

    public List<Product> getAllProducts() {
        return productDAO.getAll();
    }

    public List<Product> getAvailableProducts() {
        return productDAO.getAvailable();
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

    public void softDeleteProduct(int id) {
        productDAO.softDelete(id);
    }

    public List<Product> searchProducts(String keyword) {
        return productDAO.searchByName(keyword);
    }

    // ==================== ORDER ====================

    public Order createOrder(RestaurantTable table, OrderType orderType) {
        Order order = new Order();
        order.setTable(table);
        order.setOrderType(orderType);
        order.setOrderDate(LocalDateTime.now());
        order.setTotalAmount(0);
        order.setStatus("PENDING");
        orderDAO.insert(order);
        return order;
    }

    public void addItemToOrder(int orderId, int productId, int quantity) {
        Order order = orderDAO.getById(orderId);
        Product product = productDAO.getById(productId);

        if (order != null && product != null) {
            OrderDetail detail = new OrderDetail();
            detail.setOrder(order);
            detail.setProduct(product);
            detail.setQuantity(quantity);
            detail.setUnitPrice(product.getPrice());
            detail.setSubtotal(product.getPrice() * quantity);
            orderDetailDAO.insert(detail);

            // Cập nhật tổng tiền
            order.setTotalAmount(order.getTotalAmount() + detail.getSubtotal());
            orderDAO.update(order);
        }
    }

    public List<Order> getPendingOrders() {
        return orderDAO.getByStatus("PENDING");
    }

    public List<Order> getOrdersByTable(int tableId) {
        return orderDAO.getByTable(tableId);
    }

    public List<OrderDetail> getOrderDetails(int orderId) {
        return orderDetailDAO.getByOrderId(orderId);
    }

    // ==================== CHECKOUT ====================

    public Payment checkout(int orderId, String paymentMethod) {
        Order order = orderDAO.getById(orderId);
        if (order == null || !"PENDING".equals(order.getStatus())) {
            return null;
        }

        // Tạo thanh toán
        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setPaymentMethod(paymentMethod);
        payment.setAmount(order.getTotalAmount());
        payment.setPaymentDate(LocalDateTime.now());
        paymentDAO.insert(payment);

        // Cập nhật trạng thái đơn hàng
        order.setStatus("COMPLETED");
        orderDAO.update(order);

        return payment;
    }

    public void cancelOrder(int orderId) {
        Order order = orderDAO.getById(orderId);
        if (order != null) {
            order.setStatus("CANCELLED");
            orderDAO.update(order);
        }
    }
}
