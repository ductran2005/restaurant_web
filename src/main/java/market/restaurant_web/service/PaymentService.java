package market.restaurant_web.service;

import market.restaurant_web.dao.*;
import market.restaurant_web.entity.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * PaymentService - Xác nhận đơn, thanh toán, trừ tồn kho.
 * (Kết hợp từ restaurant-ipos-java)
 */
public class PaymentService {
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderDetailDAO detailDAO = new OrderDetailDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final TableDAO tableDAO = new TableDAO();

    /**
     * Xác nhận đơn hàng (chuyển từ OPEN → SERVED).
     * Trừ tồn kho ngay khi xác nhận.
     */
    public void confirm(int orderId) {
        Order order = orderDAO.getById(orderId);
        if (order == null) {
            throw new RuntimeException("Không tìm thấy đơn hàng: " + orderId);
        }
        if (!"OPEN".equals(order.getStatus())) {
            throw new RuntimeException("Chỉ có thể xác nhận đơn đang OPEN.");
        }

        order.setStatus("SERVED");
        orderDAO.update(order);

        // Trừ tồn kho
        subtractInventory(orderId);
    }

    /**
     * Thanh toán đơn hàng.
     *
     * @param orderId    id đơn
     * @param amountPaid số tiền khách trả
     * @param method     CASH/CARD/TRANSFER
     * @param cashierId  người thu tiền
     */
    public boolean processPayment(int orderId, BigDecimal amountPaid,
            String method, int cashierId) {
        Order order = orderDAO.getById(orderId);
        if (order == null || "PAID".equals(order.getStatus()) || "CANCELLED".equals(order.getStatus())) {
            return false;
        }

        // Nếu đơn còn OPEN (chưa confirm), trừ kho trước
        if ("OPEN".equals(order.getStatus())) {
            subtractInventory(orderId);
        }

        // Tạo payment
        Payment p = new Payment();
        p.setOrderId(orderId);
        p.setCashierId(cashierId);
        p.setPaidAt(LocalDateTime.now());
        p.setMethod(method);
        p.setAmountPaid(amountPaid);
        p.setDiscountAmount(order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO);
        p.setFinalAmount(order.getTotalAmount() != null ? order.getTotalAmount() : BigDecimal.ZERO);
        p.setPaymentStatus("SUCCESS");

        paymentDAO.insert(p);

        // Cập nhật đơn → PAID
        order.setStatus("PAID");
        order.setClosedAt(LocalDateTime.now());
        orderDAO.update(order);

        // Giải phóng bàn
        RestaurantTable table = order.getTable();
        if (table != null) {
            table.setStatus("AVAILABLE");
            tableDAO.update(table);
        }

        return true;
    }

    /**
     * Trừ tồn kho dựa trên chi tiết đơn hàng.
     */
    private void subtractInventory(int orderId) {
        List<OrderDetail> details = detailDAO.getByOrderId(orderId);
        for (OrderDetail d : details) {
            try {
                inventoryDAO.subtract(d.getProduct().getProductId(), d.getQuantity());
            } catch (RuntimeException e) {
                // Log lỗi nhưng không dừng thanh toán (tồn kho có thể chưa setup)
                System.err.println("Cảnh báo tồn kho: " + e.getMessage());
            }
        }
    }
}
