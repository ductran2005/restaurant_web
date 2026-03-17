package market.restaurant_web.controller.user;

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
 * User pre-order page — /user/pre-order
 * Same logic as PreOrderPageController, routes to user views.
 */
@WebServlet("/user/pre-order")
public class UserPreOrderPageController extends HttpServlet {

    private final BookingDao bookingDao = new BookingDao();
    private final ProductDAO productDao = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");
        String phone = req.getParameter("phone");

        if ((code == null || code.isBlank()) && (phone == null || phone.isBlank())) {
            req.setAttribute("navActive", "preorder");
            req.getRequestDispatcher("/WEB-INF/views/user/pre-order.jsp").forward(req, resp);
            return;
        }

        Booking booking = null;
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            if (code != null && !code.isBlank()) {
                booking = bookingDao.findByCode(s, code.trim());
            } else if (phone != null && !phone.isBlank()) {
                List<Booking> bookings = bookingDao.findByPhone(s, phone.trim());
                if (!bookings.isEmpty()) booking = bookings.get(0);
            }

            if (booking == null) {
                req.setAttribute("error", "Không tìm thấy booking với thông tin này");
                req.setAttribute("navActive", "preorder");
                req.getRequestDispatcher("/WEB-INF/views/user/pre-order.jsp").forward(req, resp);
                return;
            }

            String status = booking.getStatus();
            if (!"PENDING".equals(status) && !"CONFIRMED".equals(status)) {
                req.setAttribute("error", "Booking này không thể đặt món trước (status: " + status + ")");
                req.setAttribute("navActive", "preorder");
                req.getRequestDispatcher("/WEB-INF/views/user/pre-order.jsp").forward(req, resp);
                return;
            }

            List<PreOrderItem> items = s.createQuery(
                "FROM PreOrderItem WHERE booking.id = :bookingId", PreOrderItem.class)
                .setParameter("bookingId", booking.getId()).list();
            List<PreOrderItem> preOrderItems = new ArrayList<>(items);

            List<Product> menuItems = productDao.findAvailable(s);
            List<Category> categories = s.createQuery("FROM Category ORDER BY categoryName", Category.class).list();

            BigDecimal cartTotal = BigDecimal.ZERO;
            for (PreOrderItem item : preOrderItems) {
                cartTotal = cartTotal.add(item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity())));
            }

            LocalDateTime bookingDateTime = LocalDateTime.of(booking.getBookingDate(), booking.getBookingTime());
            LocalDateTime cutoffTime = bookingDateTime.minusMinutes(60);
            LocalDateTime now = LocalDateTime.now();
            boolean cutoffOk = now.isBefore(cutoffTime);
            String cutoffDisplay;
            if (cutoffOk) {
                Duration duration = Duration.between(now, cutoffTime);
                long hours = duration.toHours();
                long minutes = duration.toMinutes() % 60;
                cutoffDisplay = hours > 0 ? hours + " giờ " + minutes + " phút" : minutes + " phút";
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

        req.setAttribute("navActive", "preorder");
        req.getRequestDispatcher("/WEB-INF/views/user/pre-order.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String bookingCode = req.getParameter("bookingCode");

        if (bookingCode == null || bookingCode.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/user/pre-order");
            return;
        }

        try {
            switch (action) {
                case "add":     handleAdd(req); break;
                case "updateQty": handleUpdateQty(req); break;
                case "remove":  handleRemove(req); break;
                case "confirm":
                    resp.sendRedirect(req.getContextPath() + "/user/pre-order/checkout?code=" + bookingCode);
                    return;
                default: break;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }

        resp.sendRedirect(req.getContextPath() + "/user/pre-order?code=" + bookingCode);
    }

    private void handleAdd(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            String bookingCode = req.getParameter("bookingCode");
            int productId = Integer.parseInt(req.getParameter("productId"));
            Booking booking = bookingDao.findByCode(s, bookingCode);
            if (booking == null) throw new RuntimeException("Booking không tồn tại");
            if (booking.isPreorderLocked()) throw new RuntimeException("Đã quá thời gian cho phép đặt món trước");
            Product product = productDao.findById(s, productId);
            if (product == null || !"AVAILABLE".equals(product.getStatus())) throw new RuntimeException("Món không có sẵn");

            List<PreOrderItem> existing = s.createQuery(
                "FROM PreOrderItem WHERE booking.id = :bookingId AND product.id = :productId", PreOrderItem.class)
                .setParameter("bookingId", booking.getId()).setParameter("productId", productId).list();

            if (!existing.isEmpty()) {
                PreOrderItem item = existing.get(0);
                item.setQuantity(item.getQuantity() + 1);
                s.merge(item);
            } else {
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
        } finally { s.close(); }
    }

    private void handleUpdateQty(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            int itemId = Integer.parseInt(req.getParameter("itemId"));
            int delta = Integer.parseInt(req.getParameter("delta"));
            PreOrderItem item = s.get(PreOrderItem.class, itemId);
            if (item == null) throw new RuntimeException("Món không tồn tại");
            if (item.getBooking().isPreorderLocked()) throw new RuntimeException("Đã quá thời gian cho phép sửa món");
            int newQty = item.getQuantity() + delta;
            if (newQty <= 0) { s.remove(item); } else { item.setQuantity(newQty); s.merge(item); }
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally { s.close(); }
    }

    private void handleRemove(HttpServletRequest req) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            int itemId = Integer.parseInt(req.getParameter("itemId"));
            PreOrderItem item = s.get(PreOrderItem.class, itemId);
            if (item == null) throw new RuntimeException("Món không tồn tại");
            if (item.getBooking().isPreorderLocked()) throw new RuntimeException("Đã quá thời gian cho phép xóa món");
            s.remove(item);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally { s.close(); }
    }
}
