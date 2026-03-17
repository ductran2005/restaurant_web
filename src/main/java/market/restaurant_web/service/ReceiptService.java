package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.OrderDAO;
import market.restaurant_web.dao.PaymentDAO;
import market.restaurant_web.entity.*;
import org.hibernate.Session;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Service for generating receipt content after successful payment.
 */
public class ReceiptService {
    private final OrderDAO orderDao = new OrderDAO();
    private final PaymentDAO paymentDao = new PaymentDAO();
    private final ConfigService configService = new ConfigService();

    /**
     * Generate receipt text for a paid order.
     */
    public String generateReceipt(int orderId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Order order = orderDao.findById(s, orderId);
            if (order == null) {
                throw new RuntimeException("Order không tồn tại");
            }
            
            if (!"PAID".equals(order.getStatus())) {
                throw new RuntimeException("Order chưa được thanh toán");
            }

            Payment payment = paymentDao.findByOrderId(s, orderId);
            if (payment == null) {
                throw new RuntimeException("Không tìm thấy thông tin thanh toán");
            }

            // Load order details
            List<OrderDetail> details = s.createQuery(
                "FROM OrderDetail WHERE order.id = :oid AND itemStatus = 'ORDERED'", 
                OrderDetail.class)
                .setParameter("oid", orderId)
                .list();

            return buildReceiptText(order, payment, details);
        }
    }

    private String buildReceiptText(Order order, Payment payment, List<OrderDetail> details) {
        StringBuilder receipt = new StringBuilder();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        
        // Restaurant info
        String restaurantName = configService.getValue("RESTAURANT_NAME");
        String restaurantAddress = configService.getValue("RESTAURANT_ADDRESS");
        String restaurantPhone = configService.getValue("RESTAURANT_PHONE");
        
        if (restaurantName == null) restaurantName = "NHÀ HÀNG";
        if (restaurantAddress == null) restaurantAddress = "";
        if (restaurantPhone == null) restaurantPhone = "";

        receipt.append("========================================\n");
        receipt.append("          ").append(restaurantName).append("\n");
        if (!restaurantAddress.isEmpty()) {
            receipt.append("     ").append(restaurantAddress).append("\n");
        }
        if (!restaurantPhone.isEmpty()) {
            receipt.append("          Tel: ").append(restaurantPhone).append("\n");
        }
        receipt.append("========================================\n");
        receipt.append("              HÓA ĐƠN BÁN HÀNG\n");
        receipt.append("========================================\n\n");

        // Order info
        receipt.append("Mã đơn hàng: #").append(order.getId()).append("\n");
        if (order.getTable() != null) {
            receipt.append("Bàn: ").append(order.getTable().getTableNumber());
            if (order.getTable().getArea() != null) {
                receipt.append(" (").append(order.getTable().getArea().getAreaName()).append(")");
            }
            receipt.append("\n");
        }
        if (order.getCreatedByUser() != null) {
            receipt.append("Nhân viên: ").append(order.getCreatedByUser().getFullName()).append("\n");
        }
        receipt.append("Ngày: ").append(order.getCreatedAt().format(dateFormatter)).append("\n");
        receipt.append("\n");

        // Items
        receipt.append("----------------------------------------\n");
        receipt.append(String.format("%-20s %5s %10s\n", "Món", "SL", "Thành tiền"));
        receipt.append("----------------------------------------\n");

        for (OrderDetail detail : details) {
            String productName = detail.getProduct() != null ? 
                detail.getProduct().getProductName() : "Unknown";
            
            // Truncate long names
            if (productName.length() > 20) {
                productName = productName.substring(0, 17) + "...";
            }
            
            BigDecimal lineTotal = detail.getUnitPrice()
                .multiply(BigDecimal.valueOf(detail.getQuantity()));
            
            receipt.append(String.format("%-20s %5d %,10.0f\n", 
                productName, 
                detail.getQuantity(), 
                lineTotal.doubleValue()));
        }

        receipt.append("----------------------------------------\n");

        // Totals
        BigDecimal subtotal = order.getSubtotal() != null ? order.getSubtotal() : BigDecimal.ZERO;
        BigDecimal discount = order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal total = order.getTotalAmount() != null ? order.getTotalAmount() : BigDecimal.ZERO;

        receipt.append(String.format("%-26s %,10.0f\n", "Tạm tính:", subtotal.doubleValue()));
        if (discount.compareTo(BigDecimal.ZERO) > 0) {
            receipt.append(String.format("%-26s -%,9.0f\n", "Giảm giá:", discount.doubleValue()));
        }
        receipt.append("========================================\n");
        receipt.append(String.format("%-26s %,10.0f\n", "TỔNG CỘNG:", total.doubleValue()));
        receipt.append("========================================\n\n");

        // Payment info
        receipt.append("Phương thức: ").append(getPaymentMethodName(payment.getMethod())).append("\n");
        receipt.append("Thanh toán: ").append(String.format("%,d", payment.getAmountPaid().longValue())).append(" đ\n");
        
        BigDecimal change = payment.getAmountPaid().subtract(total);
        if (change.compareTo(BigDecimal.ZERO) > 0) {
            receipt.append("Tiền thừa: ").append(String.format("%,d", change.longValue())).append(" đ\n");
        }
        
        if (payment.getTransactionRef() != null && !payment.getTransactionRef().isEmpty()) {
            receipt.append("Mã GD: ").append(payment.getTransactionRef()).append("\n");
        }
        
        if (payment.getCashier() != null) {
            receipt.append("Thu ngân: ").append(payment.getCashier().getFullName()).append("\n");
        }
        
        receipt.append("Thời gian: ").append(payment.getPaidAt().format(dateFormatter)).append("\n");
        receipt.append("\n");

        // Footer
        receipt.append("========================================\n");
        receipt.append("       Cảm ơn quý khách!\n");
        receipt.append("         Hẹn gặp lại!\n");
        receipt.append("========================================\n");

        return receipt.toString();
    }

    private String getPaymentMethodName(String method) {
        if (method == null) return "Không xác định";
        switch (method.toUpperCase()) {
            case "CASH": return "Tiền mặt";
            case "TRANSFER": return "Chuyển khoản";
            case "CARD": return "Thẻ";
            case "MOMO": return "MoMo";
            case "VNPAY": return "VNPay";
            default: return method;
        }
    }
}
