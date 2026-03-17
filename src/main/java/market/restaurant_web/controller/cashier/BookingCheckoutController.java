package market.restaurant_web.controller.cashier;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.PreOrderItem;
import market.restaurant_web.service.ConfigService;
import org.hibernate.Session;
import org.hibernate.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Cashier Booking Checkout — /cashier/booking-checkout
 * Allows cashier to checkout a pre-order booking:
 *   - Show pre-order items, totals (VAT + service fee), deposit already paid, amount due
 *   - Confirm payment → mark booking COMPLETED → redirect to printable bill
 */
@WebServlet("/cashier/booking-checkout")
public class BookingCheckoutController extends HttpServlet {

    private final BookingDao bookingDao = new BookingDao();
    private final ConfigService configService = new ConfigService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");

        if (code == null || code.isBlank()) {
            // Show search form only
            req.getRequestDispatcher("/WEB-INF/views/cashier/booking-checkout.jsp").forward(req, resp);
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Booking booking = session.createQuery(
                    "SELECT DISTINCT b FROM Booking b " +
                    "LEFT JOIN FETCH b.preOrderItems poi " +
                    "LEFT JOIN FETCH poi.product " +
                    "LEFT JOIN FETCH b.table " +
                    "WHERE UPPER(b.bookingCode) = :c", Booking.class)
                    .setParameter("c", code.toUpperCase().trim())
                    .uniqueResult();

            if (booking == null) {
                req.setAttribute("error", "Không tìm thấy booking mã: " + code);
                req.getRequestDispatcher("/WEB-INF/views/cashier/booking-checkout.jsp").forward(req, resp);
                return;
            }

            List<PreOrderItem> rawItems = booking.getPreOrderItems();
            List<PreOrderItem> items = (rawItems != null) ? new ArrayList<>(rawItems) : new ArrayList<>();

            // Calculate subtotal
            BigDecimal subtotal = BigDecimal.ZERO;
            for (PreOrderItem poi : items) {
                if (poi.getProduct() != null && poi.getProduct().getPrice() != null) {
                    int qty = poi.getQuantity() != null ? poi.getQuantity() : 1;
                    subtotal = subtotal.add(poi.getProduct().getPrice().multiply(new BigDecimal(qty)));
                }
            }

            // Read rates from config
            BigDecimal vatRate = parseRate(configService.getValue("vat_rate"), BigDecimal.TEN);
            BigDecimal serviceFeeRate = parseRate(configService.getValue("service_fee_rate"), new BigDecimal("5"));

            BigDecimal vatAmount = subtotal.multiply(vatRate)
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
            BigDecimal serviceFeeAmount = subtotal.multiply(serviceFeeRate)
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
            BigDecimal grandTotal = subtotal.add(vatAmount).add(serviceFeeAmount);
            BigDecimal deposit = booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO;
            BigDecimal amountDue = grandTotal.subtract(deposit).max(BigDecimal.ZERO);

            req.setAttribute("booking", booking);
            req.setAttribute("items", items);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("vatRate", vatRate);
            req.setAttribute("vatAmount", vatAmount);
            req.setAttribute("serviceFeeRate", serviceFeeRate);
            req.setAttribute("serviceFeeAmount", serviceFeeAmount);
            req.setAttribute("grandTotal", grandTotal);
            req.setAttribute("deposit", deposit);
            req.setAttribute("amountDue", amountDue);
        }

        req.getRequestDispatcher("/WEB-INF/views/cashier/booking-checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String code = req.getParameter("bookingCode");
        String method = req.getParameter("paymentMethod");

        if (code == null || code.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/cashier/booking-checkout");
            return;
        }

        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findByCode(s, code.trim());
            if (booking == null) throw new RuntimeException("Booking không tồn tại: " + code);
            if ("COMPLETED".equals(booking.getStatus()))
                throw new RuntimeException("Booking này đã được thanh toán");

            booking.setStatus("COMPLETED");
            booking.setDepositRef((booking.getDepositRef() != null ? booking.getDepositRef() : "")
                    + "|FINAL-" + (method != null ? method : "CASH") + "-" + System.currentTimeMillis());
            booking.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, booking);
            tx.commit();

            // Redirect to printable bill
            resp.sendRedirect(req.getContextPath() + "/cashier/booking-checkout/bill?code=" + code);

        } catch (Exception e) {
            if (tx != null) tx.rollback();
            req.getSession().setAttribute("flash_msg", "Lỗi: " + e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
            resp.sendRedirect(req.getContextPath() + "/cashier/booking-checkout?code=" + code);
        } finally {
            s.close();
        }
    }

    private BigDecimal parseRate(String val, BigDecimal def) {
        if (val == null || val.isBlank()) return def;
        try { return new BigDecimal(val.trim()); }
        catch (NumberFormatException e) { return def; }
    }
}
