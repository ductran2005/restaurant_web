package market.restaurant_web.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.ProductDAO;
import market.restaurant_web.entity.Product;
import org.hibernate.Session;

import java.io.*;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.text.NumberFormat;
import java.time.Duration;
import java.util.*;

/**
 * ChatbotApiServlet — proxy to Groq API with live DB menu injection
 * Endpoint: POST /chatbot-api
 * Request: {"message": "user text"}
 * Response: {"reply": "bot text"} | {"error": "..."}
 */
@WebServlet("/chatbot-api")
public class ChatbotApiServlet extends HttpServlet {

    // ──────────────────────────────────────────────
    // Groq Configuration (free tier, OpenAI-compatible)
    // ──────────────────────────────────────────────
    private static final String GROQ_API_KEY = "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";
    private static final String GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
    private static final String MODEL = "llama-3.3-70b-versatile";

    /** Static part of system prompt — restaurant info */
    private static final String BASE_SYSTEM_PROMPT = "Bạn là trợ lý AI của nhà hàng Hương Việt — nhà hàng ẩm thực Việt Nam tại TP.HCM.\n"
            +
            "Thông tin cơ bản:\n" +
            "- Địa chỉ: 123 Nguyễn Huệ, Quận 1, TP.HCM\n" +
            "- Hotline: 0901 234 567\n" +
            "- Giờ mở cửa: Thứ 2–6: 10:00–22:00 | Thứ 7–CN: 08:00–23:00\n" +
            "- Ưu đãi: Giảm 15% khi đặt trước 2 ngày, combo gia đình 4 người giảm 20%, sinh nhật miễn phí tráng miệng\n"
            +
            "- Có phòng VIP, sảnh tiệc cho nhóm 5–200 người\n" +
            "Hãy trả lời ngắn gọn, thân thiện, bằng tiếng Việt. " +
            "Chỉ trả lời trong phạm vi liên quan đến nhà hàng. " +
            "Nếu câu hỏi không liên quan, hãy lịch sự hướng người dùng về chủ đề nhà hàng.";

    private HttpClient httpClient;
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    public void init() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(15))
                .build();
    }

    // ──────────────────────────────────────────────
    // Build dynamic system prompt with live DB menu
    // ──────────────────────────────────────────────
    private String buildSystemPrompt() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<Product> products = productDAO.findAvailable(session);
            if (products == null || products.isEmpty()) {
                return BASE_SYSTEM_PROMPT;
            }

            // Group by category
            Map<String, List<Product>> byCategory = new LinkedHashMap<>();
            for (Product p : products) {
                String cat = p.getCategory() != null ? p.getCategory().getCategoryName() : "Khác";
                byCategory.computeIfAbsent(cat, k -> new ArrayList<>()).add(p);
            }

            // Build menu text
            NumberFormat fmt = NumberFormat.getIntegerInstance(new Locale("vi", "VN"));
            StringBuilder menu = new StringBuilder("\nThực đơn hiện tại (chỉ các món đang phục vụ):\n");
            for (Map.Entry<String, List<Product>> entry : byCategory.entrySet()) {
                menu.append("== ").append(entry.getKey()).append(" ==\n");
                for (Product p : entry.getValue()) {
                    menu.append("• ").append(p.getProductName());
                    if (p.getPrice() != null) {
                        menu.append(": ").append(fmt.format(p.getPrice())).append(" VNĐ");
                    }
                    if (p.getDescription() != null && !p.getDescription().isBlank()) {
                        menu.append(" — ").append(p.getDescription().trim());
                    }
                    menu.append("\n");
                }
            }

            return BASE_SYSTEM_PROMPT + menu;

        } catch (Exception e) {
            // DB unavailable — fall back to static prompt
            getServletContext().log("ChatbotApiServlet: DB unavailable, using static prompt", e);
            return BASE_SYSTEM_PROMPT;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");

        // ── 1. Read request body ──
        String body;
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(req.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null)
                sb.append(line);
            body = sb.toString();
        }

        String userMessage = extractJsonString(body, "message");
        if (userMessage == null || userMessage.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"message is required\"}");
            return;
        }

        // ── 2. Build system prompt with live menu ──
        String systemPrompt = buildSystemPrompt();

        // ── 3. Build Groq API payload ──
        String payload = "{"
                + "\"model\":\"" + MODEL + "\","
                + "\"messages\":["
                + "{\"role\":\"system\",\"content\":" + jsonString(systemPrompt) + "},"
                + "{\"role\":\"user\",\"content\":" + jsonString(userMessage) + "}"
                + "],"
                + "\"max_tokens\":512,"
                + "\"temperature\":0.7"
                + "}";

        // ── 4. Call Groq API ──
        HttpRequest httpReq = HttpRequest.newBuilder()
                .uri(URI.create(GROQ_API_URL))
                .timeout(Duration.ofSeconds(30))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + GROQ_API_KEY)
                .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> httpResp;
        try {
            httpResp = httpClient.send(httpReq, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            resp.setStatus(503);
            resp.getWriter().write("{\"error\":\"Request interrupted\"}");
            return;
        } catch (Exception e) {
            resp.setStatus(502);
            resp.getWriter().write("{\"error\":\"Cannot reach Groq: " + escapeJson(e.getMessage()) + "\"}");
            return;
        }

        // ── 5. Parse and return reply ──
        if (httpResp.statusCode() != 200) {
            resp.setStatus(httpResp.statusCode());
            resp.getWriter().write("{\"error\":\"Groq error " + httpResp.statusCode() + "\"}");
            return;
        }

        String reply = extractChoiceContent(httpResp.body());
        if (reply == null) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Could not parse Groq response\"}");
            return;
        }

        resp.setStatus(200);
        resp.getWriter().write("{\"reply\":" + jsonString(reply) + "}");
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) {
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
        resp.setStatus(200);
    }

    // ──────────────────────────────────────────────
    // Micro JSON helpers (no extra dependencies)
    // ──────────────────────────────────────────────

    private static String jsonString(String s) {
        if (s == null)
            return "null";
        return "\"" + escapeJson(s) + "\"";
    }

    private static String escapeJson(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private static String extractJsonString(String json, String key) {
        if (json == null)
            return null;
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0)
            return null;
        idx = json.indexOf(':', idx + search.length());
        if (idx < 0)
            return null;
        idx = json.indexOf('"', idx);
        if (idx < 0)
            return null;
        int start = idx + 1;
        StringBuilder sb = new StringBuilder();
        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '\\' && i + 1 < json.length()) {
                char next = json.charAt(i + 1);
                switch (next) {
                    case '"':
                        sb.append('"');
                        i++;
                        break;
                    case '\\':
                        sb.append('\\');
                        i++;
                        break;
                    case 'n':
                        sb.append('\n');
                        i++;
                        break;
                    case 'r':
                        sb.append('\r');
                        i++;
                        break;
                    case 't':
                        sb.append('\t');
                        i++;
                        break;
                    default:
                        sb.append(c);
                }
            } else if (c == '"') {
                break;
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    private static String extractChoiceContent(String json) {
        if (json == null)
            return null;
        int choicesIdx = json.indexOf("\"choices\"");
        if (choicesIdx < 0)
            return null;
        int contentIdx = json.indexOf("\"content\"", choicesIdx);
        if (contentIdx < 0)
            return null;
        return extractJsonString(json.substring(contentIdx), "content");
    }
}
