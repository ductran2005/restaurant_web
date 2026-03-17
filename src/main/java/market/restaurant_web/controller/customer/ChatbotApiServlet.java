package market.restaurant_web.controller.customer;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.entity.*;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.ConfigService;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * ChatbotApiServlet — Google Gemini AI Agent with Function Calling
 * POST /chatbot-api { "message": "..." }
 * Config keys: GEMINI_API_KEY, GEMINI_MODEL
 */
@WebServlet("/chatbot-api")
public class ChatbotApiServlet extends HttpServlet {

    private static final String GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta/models/";
    private static final String DEFAULT_MDL = "gemini-2.5-flash";
    private static final int MAX_LOOPS = 6;
    private static final int MAX_HISTORY = 30;

    private volatile String cachedKey;
    private volatile String cachedModel;
    private volatile long cacheTs;
    private static final long TTL = 5 * 60_000L;

    private static final String SYS = """
            Bạn là nhân viên hỗ trợ AI của Nhà hàng Hương Việt (123 Nguyễn Huệ, Q1, TP.HCM).
            Giờ mở cửa: 10:00-23:00 hàng ngày. Hotline: 1900 1234.
            Nhiệm vụ: Hỗ trợ khách hàng TỰ NHIÊN, THÂN THIỆN.
            Quy tắc:
            1. Chỉ hỏi thông tin CÒN THIẾU, không hỏi lại thông tin đã có.
            2. Khi đủ dữ liệu, GỌI TOOL NGAY.
            3. Chỉ xác nhận thành công khi tool trả về success.
            4. Nếu tool lỗi, nêu lý do ngắn gọn.
            5. Luôn trả lời tiếng Việt, xưng "em", gọi "anh/chị".
            6. KHÔNG dùng markdown. Viết văn xuôi tự nhiên.
            7. Booking phải trước ít nhất 1 giờ, trong giờ 10:00-23:00.
            8. Sau khi đặt bàn thành công, hỏi có muốn đặt món trước không.
            9. Nếu khách CHƯA ĐĂNG NHẬP và muốn đặt bàn/đặt món: báo cần đăng nhập và kèm [[LOGIN_REQUIRED]] cuối câu.
               Khách chưa đăng nhập VẪN có thể hỏi thông tin nhà hàng, xem menu bình thường.
            """;

    private static final String FUNC_DECLS = """
            [
              {"name":"create_booking","description":"Tạo đặt bàn mới khi đủ: tên, điện thoại, ngày, giờ, số khách.",
               "parameters":{"type":"OBJECT","required":["customerName","phone","bookingDate","bookingTime","guestCount"],
                 "properties":{"customerName":{"type":"STRING"},"phone":{"type":"STRING"},
                   "bookingDate":{"type":"STRING","description":"YYYY-MM-DD"},"bookingTime":{"type":"STRING","description":"HH:mm"},
                   "guestCount":{"type":"INTEGER"},"note":{"type":"STRING"}}}},
              {"name":"check_booking_status","description":"Kiểm tra trạng thái booking.",
               "parameters":{"type":"OBJECT","properties":{"bookingCode":{"type":"STRING"},"phone":{"type":"STRING"}}}},
              {"name":"cancel_booking","description":"Hủy booking sau khi khách xác nhận.",
               "parameters":{"type":"OBJECT","properties":{"bookingCode":{"type":"STRING"},"phone":{"type":"STRING"},"reason":{"type":"STRING"}}}},
              {"name":"add_preorder","description":"Thêm món đặt trước cho booking.",
               "parameters":{"type":"OBJECT","required":["bookingCode","items"],
                 "properties":{"bookingCode":{"type":"STRING"},
                   "items":{"type":"ARRAY","items":{"type":"OBJECT","required":["productName","quantity"],
                     "properties":{"productName":{"type":"STRING"},"quantity":{"type":"INTEGER"},"note":{"type":"STRING"}}}}}}},
              {"name":"get_menu","description":"Lấy danh sách món ăn trong thực đơn.",
               "parameters":{"type":"OBJECT","properties":{"category":{"type":"STRING"}}}}
            ]
            """;

    // ── doPost ────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");

        String body = readBody(req);
        String userMsg = extractJson(body, "message");
        boolean reset = "true".equals(extractJson(body, "reset"));

        if (blank(userMsg)) {
            resp.getWriter().write("{\"reply\":\"Bạn muốn hỏi gì vậy ạ?\"}");
            return;
        }

        loadConfig();
        if (blank(cachedKey)) {
            resp.getWriter().write("{\"reply\":\"Chatbot chưa được cấu hình. Liên hệ quản trị viên.\"}");
            return;
        }

        HttpSession session = req.getSession(true);
        if (reset)
            session.removeAttribute("chatHist");

        @SuppressWarnings("unchecked")
        List<String> history = (List<String>) session.getAttribute("chatHist");
        if (history == null) {
            history = new ArrayList<>();
            session.setAttribute("chatHist", history);
        }

        User sessionUser = (User) session.getAttribute("user");
        if (history.isEmpty()) {
            if (sessionUser != null) {
                String ctx = "[TRẠNG THÁI]: Khách ĐÃ ĐĂNG NHẬP. Tên: " + esc(sessionUser.getFullName())
                        + (sessionUser.getPhone() != null ? ", SĐT: " + sessionUser.getPhone() : "")
                        + ". Dùng thông tin này khi đặt bàn, không cần hỏi lại.";
                history.add(uPart(ctx));
                history.add(mPart("Dạ em biết rồi ạ!"));
            } else {
                String ctx = "[TRẠNG THÁI]: Khách CHƯA ĐĂNG NHẬP. CÓ THỂ hỏi thông tin nhà hàng/menu bình thường."
                        + " CHỈ khi đặt bàn/đặt món mới cần nhắc đăng nhập và kèm [[LOGIN_REQUIRED]].";
                history.add(uPart(ctx));
                history.add(mPart("Dạ em hiểu!"));
            }
        }

        history.add(uPart(userMsg));

        // Agentic loop
        String finalReply = null;
        for (int loop = 0; loop < MAX_LOOPS; loop++) {
            String geminiResp = callGemini(buildRequest(history));
            if (geminiResp == null) {
                finalReply = "Không thể kết nối AI. Vui lòng thử lại sau ạ.";
                break;
            }

            String fnName = extractFnName(geminiResp);
            if (fnName != null) {
                String argsJson = extractFnArgs(geminiResp);
                history.add(mFnCallPart(fnName, argsJson));
                String result = executeTool(fnName, argsJson, req, sessionUser);
                history.add(fnRespPart(fnName, result));
            } else {
                finalReply = extractText(geminiResp);
                if (!blank(finalReply))
                    history.add(mPart(finalReply));
                break;
            }
        }

        if (blank(finalReply))
            finalReply = "Xin lỗi, hệ thống đang bận. Vui lòng thử lại ạ.";
        while (history.size() > MAX_HISTORY)
            history.remove(0);
        session.setAttribute("chatHist", history);
        resp.getWriter().write("{\"reply\":" + js(finalReply) + "}");
    }

    // ── Build Gemini request ──────────────────────────────────────
    private String buildRequest(List<String> history) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"systemInstruction\":{\"parts\":[{\"text\":").append(js(SYS)).append("}]},")
                .append("\"contents\":[");
        for (int i = 0; i < history.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append(history.get(i));
        }
        sb.append("],\"tools\":[{\"functionDeclarations\":").append(FUNC_DECLS).append("}],")
                .append("\"generationConfig\":{\"maxOutputTokens\":1024}}");
        return sb.toString();
    }

    // ── Gemini HTTP call ──────────────────────────────────────────
    private String callGemini(String body) {
        try {
            String url = GEMINI_BASE + cachedModel + ":generateContent?key=" + cachedKey;
            var rq = HttpRequest.newBuilder().uri(URI.create(url))
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(30))
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8)).build();
            var rs = HttpClient.newHttpClient().send(rq, HttpResponse.BodyHandlers.ofString());
            if (rs.statusCode() != 200) {
                System.err.println("[GeminiAgent] HTTP " + rs.statusCode() + " " + rs.body());
                return null;
            }
            return rs.body();
        } catch (Exception e) {
            System.err.println("[GeminiAgent] " + e.getMessage());
            return null;
        }
    }

    // ── Tool executor ─────────────────────────────────────────────
    private String executeTool(String name, String args, HttpServletRequest req, User user) {
        try {
            return switch (name) {
                case "create_booking" -> toolCreateBooking(args, req, user);
                case "check_booking_status" -> toolCheckBooking(args);
                case "cancel_booking" -> toolCancelBooking(args);
                case "add_preorder" -> toolAddPreorder(args, req, user);
                case "get_menu" -> toolGetMenu(args);
                default -> "{\"error\":\"Tool không tồn tại: " + esc(name) + "\"}";
            };
        } catch (Exception e) {
            return "{\"error\":\"Lỗi hệ thống: " + esc(e.getMessage()) + "\"}";
        }
    }

    // ── Tool: create_booking ──────────────────────────────────────
    private String toolCreateBooking(String args, HttpServletRequest req, User user) {
        if (user == null)
            return "{\"requireLogin\":true,\"error\":\"Đặt bàn yêu cầu đăng nhập.\"}";

        String name = extractJson(args, "customerName");
        String phone = extractJson(args, "phone");
        String dateStr = extractJson(args, "bookingDate");
        String timeStr = extractJson(args, "bookingTime");
        String guests = extractJson(args, "guestCount");
        String note = extractJson(args, "note");

        if (blank(name))
            return "{\"error\":\"Thiếu tên khách\"}";
        if (blank(phone))
            return "{\"error\":\"Thiếu số điện thoại\"}";
        if (blank(dateStr))
            return "{\"error\":\"Thiếu ngày đặt bàn\"}";
        if (blank(timeStr))
            return "{\"error\":\"Thiếu giờ đặt bàn\"}";
        if (blank(guests))
            return "{\"error\":\"Thiếu số lượng khách\"}";

        LocalDate bookingDate;
        LocalTime bookingTime;
        try {
            bookingDate = LocalDate.parse(dateStr);
        } catch (Exception e) {
            return "{\"error\":\"Ngày không hợp lệ, dùng YYYY-MM-DD\"}";
        }
        try {
            bookingTime = LocalTime.parse(timeStr.length() == 5 ? timeStr : timeStr + ":00");
        } catch (Exception e) {
            return "{\"error\":\"Giờ không hợp lệ, dùng HH:mm\"}";
        }

        if (LocalDateTime.of(bookingDate, bookingTime).isBefore(LocalDateTime.now().plusHours(1)))
            return "{\"error\":\"Phải đặt trước ít nhất 1 giờ\"}";
        if (bookingTime.isBefore(LocalTime.of(10, 0)) || bookingTime.isAfter(LocalTime.of(23, 0)))
            return "{\"error\":\"Giờ phải từ 10:00 đến 23:00\"}";

        int partySize;
        try {
            partySize = Integer.parseInt(guests.trim());
        } catch (Exception e) {
            return "{\"error\":\"Số khách không hợp lệ\"}";
        }
        if (partySize < 1 || partySize > 200)
            return "{\"error\":\"Số khách phải từ 1 đến 200\"}";

        Booking b = new Booking();
        b.setCustomerName(name.trim());
        b.setCustomerPhone(phone.replaceAll("[^+0-9]", ""));
        b.setBookingDate(bookingDate);
        b.setBookingTime(bookingTime);
        b.setPartySize(partySize);
        b.setUser(user);
        if (!blank(note) && !note.equalsIgnoreCase("không") && !note.equalsIgnoreCase("ko"))
            b.setNote(note.trim());

        new BookingService().create(b);
        req.getSession(true).setAttribute("lastBookingCode", b.getBookingCode());
        Object raw = getServletContext().getAttribute("newBookingCount");
        getServletContext().setAttribute("newBookingCount", (raw instanceof Integer i ? i : 0) + 1);

        if (!blank(user.getEmail())) {
            try {
                market.restaurant_web.service.EmailService.sendBookingConfirmation(
                        user.getEmail(), b.getCustomerName(), b.getBookingCode(),
                        bookingDate.toString(), bookingTime.toString(), partySize, b.getNote());
            } catch (Exception ignored) {
            }
        }

        return "{\"success\":true,\"bookingCode\":\"" + b.getBookingCode() + "\""
                + ",\"date\":\"" + bookingDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) + "\""
                + ",\"time\":\"" + bookingTime + "\",\"guests\":" + partySize + "}";
    }

    // ── Tool: check_booking_status ────────────────────────────────
    private String toolCheckBooking(String args) {
        String code = extractJson(args, "bookingCode");
        String phone = extractJson(args, "phone");
        BookingService bs = new BookingService();
        List<Booking> list = new ArrayList<>();
        if (!blank(code)) {
            Booking b = bs.findByCode(code.trim().toUpperCase());
            if (b != null)
                list.add(b);
        } else if (!blank(phone))
            list = bs.findByPhone(phone.replaceAll("[^+0-9]", ""));
        else
            return "{\"error\":\"Cần mã booking hoặc số điện thoại\"}";
        if (list.isEmpty())
            return "{\"found\":false,\"message\":\"Không tìm thấy booking nào\"}";
        StringBuilder sb = new StringBuilder("{\"found\":true,\"bookings\":[");
        for (int i = 0; i < list.size(); i++) {
            Booking b = list.get(i);
            if (i > 0)
                sb.append(",");
            sb.append("{\"bookingCode\":\"").append(b.getBookingCode()).append("\"")
                    .append(",\"date\":\"").append(b.getBookingDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")))
                    .append("\"")
                    .append(",\"time\":\"").append(b.getBookingTime()).append("\"")
                    .append(",\"guests\":").append(b.getPartySize())
                    .append(",\"status\":\"").append(translateStatus(b.getStatus())).append("\"")
                    .append(",\"name\":\"").append(esc(b.getCustomerName())).append("\"}");
        }
        return sb.append("]}").toString();
    }

    // ── Tool: cancel_booking ──────────────────────────────────────
    private String toolCancelBooking(String args) {
        String code = extractJson(args, "bookingCode");
        String phone = extractJson(args, "phone");
        String reason = extractJson(args, "reason");
        BookingService bs = new BookingService();
        Booking b = null;
        if (!blank(code))
            b = bs.findByCode(code.trim().toUpperCase());
        else if (!blank(phone)) {
            List<Booking> l = bs.findByPhone(phone.replaceAll("[^+0-9]", ""));
            if (!l.isEmpty())
                b = l.get(0);
        }
        if (b == null)
            return "{\"success\":false,\"message\":\"Không tìm thấy booking\"}";
        if ("CANCELLED".equals(b.getStatus()))
            return "{\"success\":false,\"message\":\"Booking đã hủy rồi\"}";
        if ("COMPLETED".equals(b.getStatus()))
            return "{\"success\":false,\"message\":\"Booking đã hoàn tất, không thể hủy\"}";
        bs.cancel(b.getId(), blank(reason) ? "Khách yêu cầu hủy qua chatbot" : reason.trim());
        return "{\"success\":true,\"bookingCode\":\"" + b.getBookingCode() + "\",\"message\":\"Đã hủy thành công\"}";
    }

    // ── Tool: add_preorder ────────────────────────────────────────
    private String toolAddPreorder(String args, HttpServletRequest req, User user) {
        if (user == null)
            return "{\"requireLogin\":true,\"error\":\"Đặt món trước yêu cầu đăng nhập.\"}";
        String bookingCode = extractJson(args, "bookingCode");
        if (blank(bookingCode)) {
            HttpSession s = req.getSession(false);
            if (s != null)
                bookingCode = (String) s.getAttribute("lastBookingCode");
        }
        if (blank(bookingCode))
            return "{\"error\":\"Cần mã booking\"}";
        BookingService bs = new BookingService();
        Booking booking = bs.findByCode(bookingCode.trim().toUpperCase());
        if (booking == null)
            return "{\"error\":\"Không tìm thấy booking " + esc(bookingCode) + "\"}";
        if ("CANCELLED".equals(booking.getStatus()))
            return "{\"error\":\"Booking đã bị hủy\"}";

        String itemsBlock = extractArrayBlock(args, "items");
        if (blank(itemsBlock))
            return "{\"error\":\"Không có danh sách món\"}";
        List<String> itemJsons = splitArrayElements(itemsBlock);
        if (itemJsons.isEmpty())
            return "{\"error\":\"Danh sách món trống\"}";

        List<String> added = new ArrayList<>(), notFound = new ArrayList<>();
        try (Session db = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = db.beginTransaction();
            try {
                Booking managed = db.get(Booking.class, booking.getId());
                for (String ij : itemJsons) {
                    String pName = extractJson(ij, "productName");
                    int qty = 1;
                    try {
                        qty = Integer.parseInt(extractJson(ij, "quantity").trim());
                    } catch (Exception ignored) {
                    }
                    String iNote = extractJson(ij, "note");
                    List<Product> prods = db
                            .createQuery("FROM Product WHERE LOWER(productName) LIKE :n AND status='AVAILABLE'",
                                    Product.class)
                            .setParameter("n", "%" + (pName != null ? pName.toLowerCase().trim() : "") + "%")
                            .setMaxResults(1).list();
                    if (prods.isEmpty()) {
                        notFound.add(pName);
                        continue;
                    }
                    PreOrderItem poi = new PreOrderItem();
                    poi.setBooking(managed);
                    poi.setProduct(prods.get(0));
                    poi.setQuantity(qty);
                    if (!blank(iNote))
                        poi.setNote(iNote.trim());
                    db.persist(poi);
                    added.add(prods.get(0).getProductName() + " x" + qty);
                }
                tx.commit();
            } catch (Exception e) {
                tx.rollback();
                throw e;
            }
        }
        StringBuilder sb = new StringBuilder("{\"success\":true,\"added\":[");
        for (int i = 0; i < added.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append("\"").append(esc(added.get(i))).append("\"");
        }
        sb.append("]");
        if (!notFound.isEmpty()) {
            sb.append(",\"notFound\":[");
            for (int i = 0; i < notFound.size(); i++) {
                if (i > 0)
                    sb.append(",");
                sb.append("\"").append(esc(notFound.get(i))).append("\"");
            }
            sb.append("]");
        }
        return sb.append(",\"message\":\"Đã thêm " + added.size() + " món\"}").toString();
    }

    // ── Tool: get_menu ────────────────────────────────────────────
    private String toolGetMenu(String args) {
        String cat = extractJson(args, "category");
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Product p WHERE p.status='AVAILABLE'"
                    + (blank(cat) ? "" : " AND LOWER(p.category.name) LIKE :c")
                    + " ORDER BY p.category.name,p.productName";
            var q = s.createQuery(hql, Product.class);
            if (!blank(cat))
                q.setParameter("c", "%" + cat.toLowerCase() + "%");
            q.setMaxResults(80);
            List<Product> prods = q.list();
            if (prods.isEmpty())
                return "{\"found\":false}";
            Map<String, List<Product>> grouped = new LinkedHashMap<>();
            for (Product p : prods)
                grouped.computeIfAbsent(p.getCategory() != null ? p.getCategory().getName() : "Khác",
                        k -> new ArrayList<>()).add(p);
            StringBuilder sb = new StringBuilder("{\"found\":true,\"categories\":[");
            boolean first = true;
            for (var e : grouped.entrySet()) {
                if (!first)
                    sb.append(",");
                first = false;
                sb.append("{\"name\":\"").append(esc(e.getKey())).append("\",\"items\":[");
                boolean fi = true;
                for (Product p : e.getValue()) {
                    if (!fi)
                        sb.append(",");
                    fi = false;
                    sb.append("{\"name\":\"").append(esc(p.getProductName())).append("\",\"price\":")
                            .append(p.getPrice() != null ? p.getPrice().intValue() : 0).append("}");
                }
                sb.append("]}");
            }
            return sb.append("]}").toString();
        } catch (Exception e) {
            return "{\"error\":\"" + esc(e.getMessage()) + "\"}";
        }
    }

    // ── Config ────────────────────────────────────────────────────
    private synchronized void loadConfig() {
        long now = System.currentTimeMillis();
        if (cachedKey != null && (now - cacheTs) < TTL)
            return;
        try {
            ConfigService cs = new ConfigService();
            String k = cs.getValue("GEMINI_API_KEY"), m = cs.getValue("GEMINI_MODEL");
            cachedKey = k != null ? k : "";
            cachedModel = (m != null && !m.isBlank()) ? m : DEFAULT_MDL;
            cacheTs = now;
        } catch (Exception e) {
            System.err.println("[GeminiAgent] Config: " + e.getMessage());
        }
    }

    // ── Gemini message builders ───────────────────────────────────
    private static String uPart(String text) {
        return "{\"role\":\"user\",\"parts\":[{\"text\":" + js(text) + "}]}";
    }

    private static String mPart(String text) {
        return "{\"role\":\"model\",\"parts\":[{\"text\":" + js(text) + "}]}";
    }

    private static String mFnCallPart(String name, String argsJson) {
        return "{\"role\":\"model\",\"parts\":[{\"functionCall\":{\"name\":" + js(name) + ",\"args\":" + argsJson
                + "}}]}";
    }

    private static String fnRespPart(String name, String resultJson) {
        String obj = (resultJson.trim().startsWith("{") || resultJson.trim().startsWith("[")) ? resultJson
                : "{\"result\":" + js(resultJson) + "}";
        return "{\"role\":\"user\",\"parts\":[{\"functionResponse\":{\"name\":" + js(name) + ",\"response\":" + obj
                + "}}]}";
    }

    // ── Gemini response parsers ───────────────────────────────────
    private String extractFnName(String json) {
        int idx = json.indexOf("\"functionCall\"");
        if (idx < 0)
            return null;
        int ni = json.indexOf("\"name\"", idx);
        if (ni < 0)
            return null;
        return extractJson("{" + json.substring(ni), "name");
    }

    private String extractFnArgs(String json) {
        int idx = json.indexOf("\"args\"");
        if (idx < 0)
            return "{}";
        int s = json.indexOf('{', json.indexOf(':', idx + 5));
        if (s < 0)
            return "{}";
        int d = 0, i = s;
        for (; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{')
                d++;
            else if (c == '}') {
                d--;
                if (d == 0)
                    break;
            }
        }
        return json.substring(s, i + 1);
    }

    private String extractText(String json) {
        int pi = json.indexOf("\"parts\"");
        if (pi < 0)
            return null;
        int ti = json.indexOf("\"text\"", pi);
        if (ti < 0)
            return null;
        return extractJson("{" + json.substring(ti), "text");
    }

    // ── JSON helpers ──────────────────────────────────────────────
    static String extractJson(String json, String key) {
        if (json == null)
            return null;
        int idx = json.indexOf("\"" + key + "\"");
        if (idx < 0)
            return null;
        idx = json.indexOf(':', idx + key.length() + 2);
        if (idx < 0)
            return null;
        idx++;
        while (idx < json.length() && Character.isWhitespace(json.charAt(idx)))
            idx++;
        if (idx >= json.length())
            return null;
        char first = json.charAt(idx);
        if (first == '"') {
            int s = idx + 1;
            StringBuilder sb = new StringBuilder();
            for (int i = s; i < json.length(); i++) {
                char c = json.charAt(i);
                if (c == '\\' && i + 1 < json.length()) {
                    char n = json.charAt(++i);
                    if (n == '"')
                        sb.append('"');
                    else if (n == 'n')
                        sb.append('\n');
                    else if (n == 'r')
                        sb.append('\r');
                    else if (n == 't')
                        sb.append('\t');
                    else if (n == '\\')
                        sb.append('\\');
                    else {
                        sb.append('\\');
                        sb.append(n);
                    }
                } else if (c == '"')
                    break;
                else
                    sb.append(c);
            }
            return sb.toString();
        }
        if (first == 'n' && json.startsWith("null", idx))
            return null;
        int end = idx;
        while (end < json.length() && ",}]\n\r".indexOf(json.charAt(end)) < 0)
            end++;
        return json.substring(idx, end).trim();
    }

    private String extractArrayBlock(String json, String key) {
        if (json == null)
            return null;
        int ki = json.indexOf("\"" + key + "\"");
        if (ki < 0)
            return null;
        int ai = json.indexOf('[', ki);
        if (ai < 0)
            return null;
        int d = 0, i = ai;
        for (; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '[')
                d++;
            else if (c == ']') {
                d--;
                if (d == 0)
                    break;
            }
        }
        return json.substring(ai, i + 1);
    }

    private List<String> splitArrayElements(String arr) {
        List<String> r = new ArrayList<>();
        if (arr == null || arr.isBlank())
            return r;
        String s = arr.trim();
        if (s.startsWith("["))
            s = s.substring(1);
        if (s.endsWith("]"))
            s = s.substring(0, s.length() - 1);
        int d = 0, start = 0;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '{' || c == '[')
                d++;
            else if (c == '}' || c == ']') {
                d--;
                if (d == 0) {
                    r.add(s.substring(start, i + 1).trim());
                    start = i + 2;
                }
            }
        }
        return r;
    }

    private static String esc(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    private static String js(String s) {
        return s == null ? "null" : "\"" + esc(s) + "\"";
    }

    private static boolean blank(String s) {
        return s == null || s.isBlank();
    }

    private static String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(
                new InputStreamReader(req.getInputStream(), StandardCharsets.UTF_8))) {
            String l;
            while ((l = r.readLine()) != null)
                sb.append(l);
        }
        return sb.toString();
    }

    private static String translateStatus(String s) {
        return switch (s == null ? "" : s) {
            case "PENDING" -> "Chờ xác nhận";
            case "CONFIRMED" -> "Đã xác nhận";
            case "CHECKED_IN" -> "Đã check-in";
            case "SEATED" -> "Đang ngồi";
            case "COMPLETED" -> "Hoàn tất";
            case "CANCELLED" -> "Đã hủy";
            case "NO_SHOW" -> "Không đến";
            default -> s;
        };
    }
}
