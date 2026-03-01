package market.restaurant_web.service;

import market.restaurant_web.dao.OrderDAO;
import market.restaurant_web.dao.TableDAO;
import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.RestaurantTable;
import market.restaurant_web.entity.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * OrderService - Quản lý tạo đơn hàng.
 * (Migrated từ restaurant-ipos-java)
 */
public class OrderService {

    private final TableDAO tableDAO = new TableDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    /**
     * Tạo đơn hàng mới cho bàn. Kiểm tra:
     * 1. Bàn phải tồn tại
     * 2. Bàn phải đang AVAILABLE (trống)
     * 3. Bàn chưa có đơn đang mở
     */
    public int createOrderForTable(int tableId, User createdBy) {
        RestaurantTable table = tableDAO.getById(tableId);
        if (table == null) {
            throw new RuntimeException("Bàn không tồn tại: " + tableId);
        }

        if (!"AVAILABLE".equals(table.getStatus())) {
            throw new RuntimeException("Bàn đang sử dụng, không thể tạo đơn.");
        }

        // Kiểm tra có đơn mở chưa
        Order existingOpen = orderDAO.getOpenOrderByTableId(tableId);
        if (existingOpen != null) {
            throw new RuntimeException("Bàn này đã có đơn đang mở (Order #" + existingOpen.getOrderId() + ").");
        }

        // Tạo đơn mới
        Order order = new Order();
        order.setTable(table);
        order.setCreatedBy(createdBy);
        order.setOrderType("DINE_IN");
        order.setOpenedAt(LocalDateTime.now());
        order.setSubtotal(BigDecimal.ZERO);
        order.setDiscountAmount(BigDecimal.ZERO);
        order.setTotalAmount(BigDecimal.ZERO);
        order.setStatus("OPEN");
        orderDAO.insert(order);

        // Đổi trạng thái bàn
        table.setStatus("IN_USE");
        tableDAO.update(table);

        return order.getOrderId();
    }
}
