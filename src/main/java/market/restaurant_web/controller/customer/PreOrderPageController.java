package market.restaurant_web.controller.customer;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.dao.ProductDAO;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.Category;
import market.restaurant_web.entity.PreOrderItem;
import market.restaurant_web.entity.Product;
import org.hibernate.Session;
import org.hibernate.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Main pre-order page controller
 * Handles /pre-order route for entry form and menu display
 */
@WebServlet("/pre-order")
public class PreOrderPageController extends HttpServlet {
    
    private final BookingDao bookingDao = new BookingDao();
    private final ProductDAO productDao = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String code = req.getParameter("code");
        String phone = req.getParameter("phone");
        
        // If no params, show entry form
        if ((code == null || code.isBlank()) && (phone == null || phone.isBlank())) {
            req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
            return;
        }
        
        // Find booking
        Booking booking = null;
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            if (code != null && !code.isBlank()) {
                booking = bookingDao.findByCode(s, code.trim());
            } else if (phone != null && !phone.isBlank()) {
                List<Booking> bookings = bookingDao.findByPhone(s, phone.trim());
                if (!bookings.isEmpty()) {
                    // Get most recent booking
                    booking = bookings.get(0);
                }
            }
            
            if (booking == null) {
                req.setAttribute("error", "Không tìm thấy booking với thông tin này");
                req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
                return;
            }
            
            // Check booking status
            String status = booking.getStatus();
            if (!"PENDING".equals(status) && !"CONFIRMED".equals(status)) {
                req.setAttribute("error", "Booking này không thể đặt món trước (status: " + status + ")");
                req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
                return;
            }
            
            // Load pre-order items
            List<PreOrderItem> items = s.createQuery(
                "FROM PreOrderItem WHERE booking.id = :bookingId",
                PreOrderItem.class)
                .setParameter("bookingId", booking.getId())
                .list();
            
            // Convert to ArrayList to avoid lazy loading issues
            List<PreOrderItem> preOrderItems = new ArrayList<>(items);
            
            // Load menu items
            List<Product> menuItems = productDao.findAvailable(s);
            
            // Load categories
            List<Category> categories = s.createQuery("FROM Category ORDER BY categoryName", Category.class).list();
            
            // Calculate cart total
            BigDecimal cartTotal = BigDecimal.ZERO;
            for (PreOrderItem item : preOrderItems) {
                cartTotal = cartTotal.add(
                    item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity()))
                );
            }
            
            // Calculate cutoff time
            LocalDateTime bookingDateTime = LocalDateTime.of(booking.getBookingDate(), booking.getBookingTime());
            LocalDateTime cutoffTime = bookingDateTime.minusMinutes(60);
            LocalDateTime now = LocalDateTime.now();
            
            boolean cutoffOk = now.isBefore(cutoffTime);
            String cutoffDisplay = "";
            
            if (cutoffOk) {
                Duration duration = Duration.between(now, cutoffTime);
                long hours = duration.toHours();
                long minutes = duration.toMinutes() % 60;
                if (hours > 0) {
                    cutoffDisplay = hours + " giờ " + minutes + " phút";
                } else {
                    cutoffDisplay = minutes + " phút";
                }
            } else {
                cutoffDisplay = "Đã khóa";
            }
            
            req.setAttribute("booking", booking);
            req.setAttribute("preOrderItems", preOrderItems);
            req.setAttribute("menuItems", menuItems);
            req.setAttribute("categories", categories);
            req.setAttribute("cartTotal", cartTotal);
            req.setAttribute("cutoffOk", cutoffOk);
            req.setAttribute("cutoffDisplay", cutoffDisplay);
        }
        
        req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String bookingCode = req.getParameter("bookingCode");
        
        if (bookingCode == null || bookingCode.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/pre-order");
            return;
        }
        
        try {
            switch (action) {
                case "add":
                    handleAdd(req);
                    break;
                case "updateQty":
                    handleUpdateQty(req);
                    break;
                case "remove":
                    handleRemove(req);
                    break;
                case "confirm":
                    handleConfirm(req);
                    resp.sendRedirect(req.getContextPath() + "/pre-order/checkout?code=" + bookingCode);
                    return;
                default:
                    break;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        
        resp.sendRedirect(req.getContextPath() + "/pre-order?code=" + bookingCode);
    }

    private void handleAdd(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            String bookingCode = req.getParameter("bookingCode");
            int productId = Integer.parseInt(req.getParameter("productId"));
            
            Booking booking = bookingDao.findByCode(s, bookingCode);
            if (booking == null) {
                throw new RuntimeException("Booking không tồn tại");
            }
            
            // Check if locked
            if (booking.isPreorderLocked()) {
                throw new RuntimeException("Đã quá thời gian cho phép đặt món trước");
            }
            
            Product product = productDao.findById(s, productId);
            if (product == null || !"AVAILABLE".equals(product.getStatus())) {
                throw new RuntimeException("Món không có sẵn");
            }
            
            // Check if item already exists
            List<PreOrderItem> existing = s.createQuery(
                "FROM PreOrderItem WHERE booking.id = :bookingId AND product.id = :productId",
                PreOrderItem.class)
                .setParameter("bookingId", booking.getId())
                .setParameter("productId", productId)
                .list();
            
            if (!existing.isEmpty()) {
                // Update quantity
                PreOrderItem item = existing.get(0);
                item.setQuantity(item.getQuantity() + 1);
                s.merge(item);
            } else {
                // Create new
                PreOrderItem item = new PreOrderItem();
                item.setBooking(booking);
                item.setProduct(product);
                item.setQuantity(1);
                s.persist(item);
            }
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    private void handleUpdateQty(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            int itemId = Integer.parseInt(req.getParameter("itemId"));
            int delta = Integer.parseInt(req.getParameter("delta"));
            
            PreOrderItem item = s.get(PreOrderItem.class, itemId);
            if (item == null) {
                throw new RuntimeException("Món không tồn tại");
            }
            
            Booking booking = item.getBooking();
            if (booking.isPreorderLocked()) {
                throw new RuntimeException("Đã quá thời gian cho phép sửa món");
            }
            
            int newQty = item.getQuantity() + delta;
            if (newQty <= 0) {
                s.remove(item);
            } else {
                item.setQuantity(newQty);
                s.merge(item);
            }
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    private void handleRemove(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            int itemId = Integer.parseInt(req.getParameter("itemId"));
            
            PreOrderItem item = s.get(PreOrderItem.class, itemId);
            if (item == null) {
                throw new RuntimeException("Món không tồn tại");
            }
            
            Booking booking = item.getBooking();
            if (booking.isPreorderLocked()) {
                throw new RuntimeException("Đã quá thời gian cho phép xóa món");
            }
            
            s.remove(item);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    private void handleConfirm(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            String bookingCode = req.getParameter("bookingCode");
            int itemCount = Integer.parseInt(req.getParameter("itemCount"));

            Booking booking = bookingDao.findByCode(s, bookingCode);
            if (booking == null) throw new RuntimeException("Booking không tồn tại");
            if (booking.isPreorderLocked()) throw new RuntimeException("Đã quá thời gian cho phép đặt món trước");

            // Replace existing pre-order items
            s.createMutationQuery("DELETE FROM PreOrderItem WHERE booking.id = :bookingId")
             .setParameter("bookingId", booking.getId())
             .executeUpdate();

            for (int i = 0; i < itemCount; i++) {
                int productId = Integer.parseInt(req.getParameter("productId_" + i));
                int quantity  = Integer.parseInt(req.getParameter("quantity_" + i));
                if (quantity <= 0) continue;
                Product product = productDao.findById(s, productId);
                if (product == null) continue;
                PreOrderItem item = new PreOrderItem();
                item.setBooking(booking);
                item.setProduct(product);
                item.setQuantity(quantity);
                s.persist(item);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally { s.close(); }
    }
}
