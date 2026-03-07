package market.restaurant_web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.dao.ProductDAO;
import market.restaurant_web.dao.TableDAO;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.DiningTable;
import market.restaurant_web.entity.Product;

import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/api/chat")
public class ChatbotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        // read request body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        Jsonb jsonb = JsonbBuilder.create();
        ChatRequest chatRequest;
        try {
            chatRequest = jsonb.fromJson(sb.toString(), ChatRequest.class);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"invalid json\"}");
            return;
        }

        String userMessage = chatRequest.getMessage();
        if (userMessage == null || userMessage.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"message is required\"}");
            return;
        }

        // gather some context from database
        String contextText = collectDbContext();

        String apiKey = System.getenv("OPENAI_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"server missing API key\"}");
            return;
        }

        String prompt = "You are an assistant for a restaurant web application. " +
                "Use the following database information to answer user queries.\n" +
                contextText +
                "\nUser question: " + userMessage;

        String aiReply;
        try {
            aiReply = callOpenAi(apiKey, prompt);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"openai call failed\"}");
            return;
        }

        ChatResponse chatResponse = new ChatResponse(aiReply);
        resp.getWriter().write(jsonb.toJson(chatResponse));
    }

    private String collectDbContext() {
        StringBuilder ctx = new StringBuilder();
        ctx.append("Opening hours: 9:00 AM - 10:00 PM daily.\n");

        ProductDAO pdao = new ProductDAO();
        BookingDao bdao = new BookingDao();
        TableDAO tdao = new TableDAO();

        try (var session = pdao.openSession()) {
            List<Product> products = pdao.findAvailable(session);
            if (!products.isEmpty()) {
                ctx.append("Menu items:\n");
                for (Product p : products) {
                    ctx.append("- ").append(p.getProductName())
                            .append(" (price: ").append(p.getPrice())
                            .append(")\n");
                }
            }
        }

        try (var session = bdao.openSession()) {
            List<Booking> bookings = bdao.findByDateAndStatus(session, LocalDate.now(), "CONFIRMED");
            if (!bookings.isEmpty()) {
                ctx.append("Today's confirmed bookings:\n");
                for (Booking b : bookings) {
                    ctx.append("- ").append(b.getBookingCode())
                            .append(" for ").append(b.getCustomerName())
                            .append(" at ").append(b.getBookingTime())
                            .append(" (table: ").append(b.getTable() != null ? b.getTable().getTableName() : "?")
                            .append(")\n");
                }
            }
        }

        try (var session = tdao.openSession()) {
            List<DiningTable> tables = tdao.findAvailable(session);
            if (!tables.isEmpty()) {
                ctx.append("Available tables:\n");
                for (DiningTable t : tables) {
                    ctx.append("- ").append(t.getTableName())
                            .append(" (area: ").append(t.getArea() != null ? t.getArea().getAreaName() : "?")
                            .append(")\n");
                }
            }
        }

        return ctx.toString();
    }

    private String callOpenAi(String apiKey, String prompt) throws IOException, InterruptedException {
        HttpClient client = HttpClient.newHttpClient();
        // build request body with proper escaping
        StringBuilder sb = new StringBuilder();
        sb.append("{\"model\":\"gpt-3.5-turbo\",\"messages\":[");
        sb.append("{\"role\":\"system\",\"content\":\"");
        sb.append(escapeJson("You are a helpful restaurant chatbot. Respond concisely and use the context given."));
        sb.append("\"},");
        sb.append("{\"role\":\"user\",\"content\":\"");
        sb.append(escapeJson(prompt));
        sb.append("\"}");
        sb.append("]}");
        String requestJson = sb.toString();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(requestJson))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            throw new IOException("OpenAI API error: " + response.statusCode() + " " + response.body());
        }

        // parse the JSON to extract the assistant reply
        Jsonb jsonb = JsonbBuilder.create();
        var map = jsonb.fromJson(response.body(), java.util.Map.class);
        var choices = (java.util.List<?>) map.get("choices");
        if (choices != null && !choices.isEmpty()) {
            var first = (java.util.Map<?,?>) choices.get(0);
            var message = (java.util.Map<?,?>) first.get("message");
            if (message != null) {
                Object content = message.get("content");
                if (content != null) {
                    return content.toString().trim();
                }
            }
        }
        return "";
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    public static class ChatRequest {
        private String message;
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }

    public static class ChatResponse {
        private String reply;
        public ChatResponse() {}
        public ChatResponse(String reply) { this.reply = reply; }
        public String getReply() { return reply; }
        public void setReply(String reply) { this.reply = reply; }
    }
}
