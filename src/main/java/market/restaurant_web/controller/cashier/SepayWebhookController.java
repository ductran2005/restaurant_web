package market.restaurant_web.controller.cashier;

import market.restaurant_web.service.ConfigService;
import market.restaurant_web.service.PaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Receives webhook POST from SePay when a bank transfer is detected.
 * URL: /api/sepay/webhook
 *
 * SePay sends JSON like:
 * {
 * "id": 92704,
 * "gateway": "MBBank",
 * "transactionDate": "2023-03-25 14:02:37",
 * "accountNumber": "0123499999",
 * "code": null,
 * "content": "HV42 chuyen tien",
 * "transferType": "in",
 * "transferAmount": 150000,
 * "accumulated": 19077000,
 * "subAccount": null,
 * "referenceCode": "MBVCB.3278907687",
 * "description": ""
 * }
 *
 * This controller extracts the order ID from content (matching the prefix),
 * verifies amount, and auto-confirms payment.
 */
@WebServlet("/api/sepay/webhook")
public class SepayWebhookController extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();
    private final ConfigService configService = new ConfigService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            // Read JSON body
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String body = sb.toString();

            // Verify API Key if configured
            String configApiKey = configService.getValue("SEPAY_API_KEY");
            if (configApiKey != null && !configApiKey.isEmpty()) {
                String authHeader = req.getHeader("Authorization");
                if (authHeader == null || !authHeader.equals("Apikey " + configApiKey)) {
                    resp.setStatus(401);
                    out.print("{\"success\": false, \"message\": \"Unauthorized\"}");
                    return;
                }
            }

            // Simple JSON parsing (no external library needed)
            String transferType = extractJsonString(body, "transferType");
            if (!"in".equals(transferType)) {
                // Only process incoming transfers
                resp.setStatus(200);
                out.print("{\"success\": true, \"message\": \"Ignored outgoing transfer\"}");
                return;
            }

            String content = extractJsonString(body, "content");
            long transferAmount = extractJsonLong(body, "transferAmount");
            String referenceCode = extractJsonString(body, "referenceCode");

            if (content == null || content.isEmpty()) {
                resp.setStatus(200);
                out.print("{\"success\": true, \"message\": \"No content\"}");
                return;
            }

            // Extract order ID from content using prefix
            String prefix = configService.getValue("SEPAY_CONTENT_PREFIX");
            if (prefix == null || prefix.isEmpty())
                prefix = "HV";

            // Match pattern like HV42 or HV 42 (prefix followed by digits)
            Pattern pattern = Pattern.compile("(?i)" + Pattern.quote(prefix) + "\\s*(\\d+)");
            Matcher matcher = pattern.matcher(content.toUpperCase());

            if (!matcher.find()) {
                resp.setStatus(200);
                out.print("{\"success\": true, \"message\": \"No order code found in content\"}");
                return;
            }

            int orderId = Integer.parseInt(matcher.group(1));

            // Auto-confirm payment via TRANSFER method
            try {
                paymentService.checkoutViaTransfer(orderId, transferAmount, referenceCode);
                resp.setStatus(200);
                out.print("{\"success\": true, \"message\": \"Payment confirmed for order " + orderId + "\"}");
            } catch (RuntimeException e) {
                // Order already paid or other issue - still return success to SePay
                resp.setStatus(200);
                out.print("{\"success\": true, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
            }

        } catch (Exception e) {
            resp.setStatus(200);
            out.print("{\"success\": true, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // Simple JSON string value extraction
    private String extractJsonString(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher m = p.matcher(json);
        return m.find() ? m.group(1) : null;
    }

    // Simple JSON number extraction
    private long extractJsonLong(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*(\\d+)");
        Matcher m = p.matcher(json);
        return m.find() ? Long.parseLong(m.group(1)) : 0;
    }

    private String escapeJson(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
