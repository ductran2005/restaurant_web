package market.restaurant_web.controller.cashier;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.service.ConfigService;
import market.restaurant_web.service.PaymentService;
import org.hibernate.Session;
import org.hibernate.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Receives webhook POST from SePay when a bank transfer is detected.
 * Handles both:
 *   - Order payment:  content contains prefix + orderId  (e.g. "HV42")
 *   - Deposit payment: content contains bookingCode + " COC" (e.g. "BK6014C8BD COC")
 */
@WebServlet("/api/sepay/webhook")
public class SepayWebhookController extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();
    private final ConfigService configService = new ConfigService();
    private final BookingDao bookingDao = new BookingDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            String body = sb.toString();

            // Verify API Key
            String configApiKey = configService.getValue("SEPAY_API_KEY");
            if (configApiKey != null && !configApiKey.isEmpty()) {
                String authHeader = req.getHeader("Authorization");
                if (authHeader == null || !authHeader.equals("Apikey " + configApiKey)) {
                    resp.setStatus(401);
                    out.print("{\"success\": false, \"message\": \"Unauthorized\"}");
                    return;
                }
            }

            String transferType = extractJsonString(body, "transferType");
            if (!"in".equals(transferType)) {
                out.print("{\"success\": true, \"message\": \"Ignored outgoing transfer\"}");
                return;
            }

            String content = extractJsonString(body, "content");
            long transferAmount = extractJsonLong(body, "transferAmount");
            String referenceCode = extractJsonString(body, "referenceCode");

            if (content == null || content.isEmpty()) {
                out.print("{\"success\": true, \"message\": \"No content\"}");
                return;
            }

            String contentUpper = content.toUpperCase().trim();

            // --- Check deposit payment: content contains "BK" code + "COC" ---
            Pattern depositPattern = Pattern.compile("(BK[A-Z0-9]+)\\s+COC");
            Matcher depositMatcher = depositPattern.matcher(contentUpper);
            if (depositMatcher.find()) {
                String bookingCode = depositMatcher.group(1);
                try {
                    confirmDeposit(bookingCode, transferAmount, referenceCode);
                    out.print("{\"success\": true, \"message\": \"Deposit confirmed for booking " + bookingCode + "\"}");
                } catch (RuntimeException e) {
                    out.print("{\"success\": true, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
                }
                return;
            }

            // --- Check order payment: content contains prefix + orderId ---
            String prefix = configService.getValue("SEPAY_CONTENT_PREFIX");
            if (prefix == null || prefix.isEmpty()) prefix = "HV";

            Pattern orderPattern = Pattern.compile("(?i)" + Pattern.quote(prefix) + "\\s*(\\d+)");
            Matcher orderMatcher = orderPattern.matcher(contentUpper);

            if (!orderMatcher.find()) {
                out.print("{\"success\": true, \"message\": \"No matching code in content\"}");
                return;
            }

            int orderId = Integer.parseInt(orderMatcher.group(1));
            try {
                paymentService.checkoutViaTransfer(orderId, transferAmount, referenceCode);
                out.print("{\"success\": true, \"message\": \"Payment confirmed for order " + orderId + "\"}");
            } catch (RuntimeException e) {
                out.print("{\"success\": true, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
            }

        } catch (Exception e) {
            resp.setStatus(200);
            out.print("{\"success\": true, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void confirmDeposit(String bookingCode, long transferAmount, String referenceCode) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findByCode(s, bookingCode);
            if (b == null) throw new RuntimeException("Booking không tồn tại: " + bookingCode);
            if ("PAID".equals(b.getDepositStatus())) throw new RuntimeException("Deposit đã được thanh toán");

            b.setDepositStatus("PAID");
            b.setDepositAmount(BigDecimal.valueOf(transferAmount));
            b.setDepositRef("SEPAY-" + referenceCode);
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    private String extractJsonString(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher m = p.matcher(json);
        return m.find() ? m.group(1) : null;
    }

    private long extractJsonLong(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*(\\d+)");
        Matcher m = p.matcher(json);
        return m.find() ? Long.parseLong(m.group(1)) : 0;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
