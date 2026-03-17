package market.restaurant_web.controller.user;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.PreOrderItem;
import org.hibernate.Session;
import org.hibernate.Transaction;

import market.restaurant_web.service.ConfigService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * User pre-order checkout — /user/pre-order/checkout
 * Same logic as PreOrderCheckoutController, routes to user views.
 */
@WebServlet("/user/pre-order/checkout")
public class UserPreOrderCheckoutController extends HttpServlet {

    private static final BigDecimal DEPOSIT_RATE = new BigDecimal("0.10");
    private final BookingDao bookingDao = new BookingDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");
        if (code == null || code.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/user/pre-order");
            return;
        }

        Booking booking;
        List<PreOrderItem> items;
        BigDecimal subtotal = BigDecimal.ZERO;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            booking = session.createQuery(
                    "SELECT DISTINCT b FROM Booking b " +
                    "LEFT JOIN FETCH b.preOrderItems poi " +
                    "LEFT JOIN FETCH poi.product " +
                    "WHERE UPPER(b.bookingCode) = :c", Booking.class)
                    .setParameter("c", code.toUpperCase().trim())
                    .uniqueResult();

            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/user/pre-order");
                return;
            }

            List<PreOrderItem> raw = booking.getPreOrderItems();
            items = (raw != null) ? new ArrayList<>(raw) : new ArrayList<>();

            for (PreOrderItem poi : items) {
                if (poi != null && poi.getProduct() != null && poi.getProduct().getPrice() != null) {
                    int qty = poi.getQuantity() != null ? poi.getQuantity() : 1;
                    subtotal = subtotal.add(poi.getProduct().getPrice().multiply(new BigDecimal(qty)));
                }
            }
        }

        ConfigService configService = new ConfigService();
        BigDecimal vatRate = parseBigDecimal(configService.getValue("vat_rate"), BigDecimal.TEN);
        BigDecimal serviceFeeRate = parseBigDecimal(configService.getValue("service_fee_rate"), new BigDecimal("5"));

        BigDecimal vat = subtotal.multiply(vatRate)
                .divide(java.math.BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        BigDecimal serviceFee = subtotal.multiply(serviceFeeRate)
                .divide(java.math.BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        BigDecimal grandTotal = subtotal.add(vat).add(serviceFee);
        BigDecimal deposit = grandTotal.multiply(DEPOSIT_RATE).setScale(0, RoundingMode.CEILING);

        req.setAttribute("booking", booking);
        req.setAttribute("items", items);
        req.setAttribute("subtotal", subtotal);
        req.setAttribute("deposit", deposit);
        req.setAttribute("vat", vat);
        req.setAttribute("serviceFee", serviceFee);
        req.setAttribute("grandTotal", grandTotal);
        req.setAttribute("vatRate", vatRate);
        req.setAttribute("serviceFeeRate", serviceFeeRate);
        req.setAttribute("navActive", "preorder");

        // SePay config — always provide bank info with fallback defaults
        String bankAccount = configService.getValue("SEPAY_BANK_ACCOUNT");
        String bankName    = configService.getValue("SEPAY_BANK_NAME");
        String accountName = configService.getValue("SEPAY_ACCOUNT_NAME");
        String contentPrefix = configService.getValue("SEPAY_CONTENT_PREFIX");

        // Use fallback defaults if not configured
        if (bankAccount == null || bankAccount.isBlank()) bankAccount = "1234567890";
        if (bankName == null || bankName.isBlank())       bankName = "Vietcombank";
        if (accountName == null || accountName.isBlank()) accountName = "NGUYEN VAN A";
        if (contentPrefix == null || contentPrefix.isBlank()) contentPrefix = "";

        req.setAttribute("sepayEnabled", true);  // Always enable QR
        req.setAttribute("sepayBankAccount", bankAccount);
        req.setAttribute("sepayBankName", bankName);
        req.setAttribute("sepayAccountName", accountName);
        req.setAttribute("sepayContentPrefix", contentPrefix);

        req.getRequestDispatcher("/WEB-INF/views/user/pre-order-checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String code = req.getParameter("bookingCode");
        String method = req.getParameter("method");

        if (code == null || code.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/user/pre-order");
            return;
        }

        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findByCode(s, code.trim());
            if (booking == null) throw new RuntimeException("Booking không tồn tại");

            List<PreOrderItem> items = s.createQuery(
                "FROM PreOrderItem WHERE booking.id = :bookingId", PreOrderItem.class)
                .setParameter("bookingId", booking.getId()).list();

            BigDecimal subtotal = BigDecimal.ZERO;
            for (PreOrderItem item : items) {
                if (item.getProduct() != null && item.getProduct().getPrice() != null) {
                    subtotal = subtotal.add(item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity())));
                }
            }

            BigDecimal deposit = subtotal.multiply(DEPOSIT_RATE).setScale(0, RoundingMode.CEILING);
            booking.setDepositAmount(deposit);
            booking.setDepositStatus("PAID");
            booking.setDepositRef(method + "-" + System.currentTimeMillis());
            booking.setUpdatedAt(LocalDateTime.now());

            bookingDao.update(s, booking);
            tx.commit();

            String msg = URLEncoder.encode(
                "Đặt cọc thành công " + deposit.toString() + "đ! Nhà hàng sẽ xác nhận trong vòng 30 phút.", "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/user/pre-order?code=" + code + "&successMsg=" + msg);

        } catch (Exception e) {
            if (tx != null) tx.rollback();
            String error = URLEncoder.encode("Lỗi: " + e.getMessage(), "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/user/pre-order/checkout?code=" + code + "&error=" + error);
        } finally {
            s.close();
        }
    }

    private BigDecimal parseBigDecimal(String val, BigDecimal defaultVal) {
        if (val == null || val.isBlank()) return defaultVal;
        try { return new BigDecimal(val.trim()); }
        catch (NumberFormatException e) { return defaultVal; }
    }
}
