package market.restaurant_web.controller.user;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.PreOrderItem;
import market.restaurant_web.service.ConfigService;
import org.hibernate.Session;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

/**
 * User Booking Bill — /user/booking/bill?code=XXX
 * Shows a printable deposit bill after pre-order payment.
 */
@WebServlet("/user/booking/bill")
public class UserBookingBillController extends HttpServlet {

    private final ConfigService configService = new ConfigService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");
        if (code == null || code.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/user/pre-order");
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
                resp.sendRedirect(req.getContextPath() + "/user/pre-order");
                return;
            }

            List<PreOrderItem> rawItems = booking.getPreOrderItems();
            List<PreOrderItem> items = (rawItems != null) ? new ArrayList<>(rawItems) : new ArrayList<>();

            BigDecimal subtotal = BigDecimal.ZERO;
            for (PreOrderItem poi : items) {
                if (poi.getProduct() != null && poi.getProduct().getPrice() != null) {
                    int qty = poi.getQuantity() != null ? poi.getQuantity() : 1;
                    subtotal = subtotal.add(poi.getProduct().getPrice().multiply(new BigDecimal(qty)));
                }
            }

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

        req.getRequestDispatcher("/WEB-INF/views/user/booking-bill.jsp").forward(req, resp);
    }

    private BigDecimal parseRate(String val, BigDecimal def) {
        if (val == null || val.isBlank()) return def;
        try { return new BigDecimal(val.trim()); }
        catch (NumberFormatException e) { return def; }
    }
}
