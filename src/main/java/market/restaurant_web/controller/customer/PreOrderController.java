package market.restaurant_web.controller.customer;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.CategoryDAO;
import market.restaurant_web.dao.ProductDAO;
import market.restaurant_web.entity.*;

import org.hibernate.Session;
import org.hibernate.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/pre-order")
public class PreOrderController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    // ── How many minutes before the booking time is cutoff ──
    private static final int CUTOFF_MINUTES_BEFORE = 60;

    // ────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");
        String phone = req.getParameter("phone");

        if ((code == null || code.isBlank()) && (phone == null || phone.isBlank())) {
            // Entry step — no booking yet
            req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
            return;
        }

        // Try to find booking
        Booking booking = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            if (code != null && !code.isBlank()) {
                booking = session.createQuery(
                        "FROM Booking WHERE UPPER(bookingCode) = :c", Booking.class)
                        .setParameter("c", code.toUpperCase().trim())
                        .uniqueResult();
            } else if (phone != null && !phone.isBlank()) {
                List<Booking> list = session.createQuery(
                        "FROM Booking WHERE customerPhone = :p ORDER BY createdAt DESC", Booking.class)
                        .setParameter("p", phone.trim())
                        .setMaxResults(1)
                        .list();
                if (!list.isEmpty())
                    booking = list.get(0);
            }

            if (booking == null) {
                req.setAttribute("error", "Không tìm thấy booking. Vui lòng kiểm tra lại mã hoặc số điện thoại.");
                req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
                return;
            }

            // Only allow PENDING or CONFIRMED
            String status = booking.getStatus();
            if (!"PENDING".equals(status) && !"CONFIRMED".equals(status)) {
                req.setAttribute("error", "Booking có trạng thái \"" + status + "\" không được phép đặt món trước.");
                req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
                return;
            }

            // Force-init lazy collection while session is open
            org.hibernate.Hibernate.initialize(booking.getPreOrderItems());
            if (booking.getPreOrderItems() != null) {
                for (PreOrderItem poi : booking.getPreOrderItems()) {
                    org.hibernate.Hibernate.initialize(poi.getProduct());
                    if (poi.getProduct() != null) {
                        org.hibernate.Hibernate.initialize(poi.getProduct().getCategory());
                    }
                }
            }

            // Load categories and menu
            List<Category> categories = categoryDAO.findActive(session);
            List<Product> menuItems = productDAO.findAvailable(session);

            // Compute cutoff & timer display
            LocalDateTime cutoffTime = null;
            if (booking.getBookingDate() != null && booking.getBookingTime() != null) {
                LocalDateTime bookingDt = LocalDateTime.of(booking.getBookingDate(), booking.getBookingTime());
                cutoffTime = bookingDt.minusMinutes(CUTOFF_MINUTES_BEFORE);
            }
            boolean cutoffOk = false;
            String cutoffDisplay = null;
            if (cutoffTime != null) {
                Duration remaining = Duration.between(LocalDateTime.now(), cutoffTime);
                cutoffOk = !remaining.isNegative();
                if (cutoffOk) {
                    long h = remaining.toHours();
                    long m = remaining.toMinutesPart();
                    long s = remaining.toSecondsPart();
                    cutoffDisplay = h + "h " + m + "m " + s + "s";
                } else {
                    cutoffDisplay = "Đã hết hạn";
                }
            }

            // Cart total
            BigDecimal cartTotal = BigDecimal.ZERO;
            if (booking.getPreOrderItems() != null) {
                for (PreOrderItem poi : booking.getPreOrderItems()) {
                    if (poi.getProduct() != null && poi.getProduct().getPrice() != null) {
                        cartTotal = cartTotal.add(
                                poi.getProduct().getPrice()
                                        .multiply(new BigDecimal(poi.getQuantity() != null ? poi.getQuantity() : 1)));
                    }
                }
            }

            req.setAttribute("booking", booking);
            req.setAttribute("preOrderItems", booking.getPreOrderItems());
            req.setAttribute("categories", categories);
            req.setAttribute("menuItems", menuItems);
            req.setAttribute("cartTotal", cartTotal);
            req.setAttribute("cutoffOk", cutoffOk);
            req.setAttribute("cutoffDisplay", cutoffDisplay);
        }

        req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
    }

    // ────────────────────────────────────────────────────────
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

        switch (action == null ? "" : action) {
            case "add" -> handleAdd(req, resp, bookingCode);
            case "updateQty" -> handleUpdateQty(req, resp, bookingCode);
            case "remove" -> handleRemove(req, resp, bookingCode);
            case "confirm" -> handleConfirm(req, resp, bookingCode);
            default -> resp.sendRedirect(req.getContextPath() + "/pre-order?code=" + bookingCode);
        }
    }

    // ── ADD item ────────────────────────────────────────────
    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, String bookingCode)
            throws IOException {
        String productIdStr = req.getParameter("productId");
        if (productIdStr == null) {
            redirect(resp, req, bookingCode);
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Booking booking = findBooking(session, bookingCode);
                if (booking == null) {
                    tx.rollback();
                    redirect(resp, req, bookingCode);
                    return;
                }

                int productId = Integer.parseInt(productIdStr);
                Product product = productDAO.findById(session, productId);
                if (product == null) {
                    tx.rollback();
                    redirect(resp, req, bookingCode);
                    return;
                }

                // Check if already in cart
                PreOrderItem existing = session.createQuery(
                        "FROM PreOrderItem WHERE booking.id = :bid AND product.id = :pid", PreOrderItem.class)
                        .setParameter("bid", booking.getId())
                        .setParameter("pid", productId)
                        .uniqueResult();

                if (existing != null) {
                    existing.setQuantity(existing.getQuantity() + 1);
                    session.merge(existing);
                } else {
                    PreOrderItem poi = new PreOrderItem();
                    poi.setBooking(booking);
                    poi.setProduct(product);
                    poi.setQuantity(1);
                    session.persist(poi);
                }
                tx.commit();
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
        }
        redirect(resp, req, bookingCode);
    }

    // ── UPDATE QUANTITY ──────────────────────────────────────
    private void handleUpdateQty(HttpServletRequest req, HttpServletResponse resp, String bookingCode)
            throws IOException {
        String itemIdStr = req.getParameter("itemId");
        String deltaStr = req.getParameter("delta");
        if (itemIdStr == null || deltaStr == null) {
            redirect(resp, req, bookingCode);
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                int itemId = Integer.parseInt(itemIdStr);
                int delta = Integer.parseInt(deltaStr);
                PreOrderItem poi = session.get(PreOrderItem.class, itemId);
                if (poi != null) {
                    int newQty = poi.getQuantity() + delta;
                    if (newQty <= 0) {
                        session.remove(poi);
                    } else {
                        poi.setQuantity(newQty);
                        session.merge(poi);
                    }
                }
                tx.commit();
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
        }
        redirect(resp, req, bookingCode);
    }

    // ── REMOVE ───────────────────────────────────────────────
    private void handleRemove(HttpServletRequest req, HttpServletResponse resp, String bookingCode)
            throws IOException {
        String itemIdStr = req.getParameter("itemId");
        if (itemIdStr == null) {
            redirect(resp, req, bookingCode);
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                int itemId = Integer.parseInt(itemIdStr);
                PreOrderItem poi = session.get(PreOrderItem.class, itemId);
                if (poi != null)
                    session.remove(poi);
                tx.commit();
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
        }
        redirect(resp, req, bookingCode);
    }

    // ── CONFIRM (redirect to checkout) ──────────────────────
    private void handleConfirm(HttpServletRequest req, HttpServletResponse resp, String bookingCode)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/pre-order/checkout?code=" + bookingCode);
    }

    // ── Helpers ──────────────────────────────────────────────
    private Booking findBooking(Session session, String bookingCode) {
        return session.createQuery(
                "FROM Booking WHERE UPPER(bookingCode) = :c", Booking.class)
                .setParameter("c", bookingCode.toUpperCase().trim())
                .uniqueResult();
    }

    private void redirect(HttpServletResponse resp, HttpServletRequest req, String bookingCode)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/pre-order?code=" + bookingCode);
    }
}
