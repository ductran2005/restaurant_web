package market.restaurant_web.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.User;
import market.restaurant_web.service.BookingService;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * POST /chatbot-booking
 * Body: { name, phone, date (YYYY-MM-DD), time (HH:mm), guests, note }
 * Response: { success, bookingCode, message } | { success:false, error }
 */
@WebServlet("/chatbot-booking")
public class ChatbotBookingServlet extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");

        // Read body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(
                new InputStreamReader(req.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null) sb.append(line);
        }
        String body = sb.toString();

        String name      = extractJson(body, "name");
        String phone     = extractJson(body, "phone");
        String dateStr   = extractJson(body, "date");
        String timeStr   = extractJson(body, "time");
        String guestsStr = extractJson(body, "guests");
        String note      = extractJson(body, "note");

        // Fill from session if missing
        HttpSession session = req.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;
        if ((name  == null || name.isBlank())  && sessionUser != null) name  = sessionUser.getFullName();
        if ((phone == null || phone.isBlank()) && sessionUser != null) phone = sessionUser.getPhone();

        // Validate required fields
        if (name  == null || name.isBlank())  { error(resp, "Thiếu tên khách"); return; }
        if (phone == null || phone.isBlank())  { error(resp, "Thiếu số điện thoại"); return; }
        if (dateStr == null || dateStr.isBlank()) { error(resp, "Thiếu ngày đặt bàn"); return; }
        if (timeStr == null || timeStr.isBlank()) { error(resp, "Thiếu giờ đặt bàn"); return; }

        LocalDate bookingDate;
        LocalTime bookingTime;
        try { bookingDate = LocalDate.parse(dateStr); }
        catch (Exception e) { error(resp, "Ngày không hợp lệ (YYYY-MM-DD)"); return; }
        try { bookingTime = LocalTime.parse(timeStr.length() == 5 ? timeStr : timeStr + ":00"); }
        catch (Exception e) { error(resp, "Giờ không hợp lệ (HH:mm)"); return; }

        if (LocalDateTime.of(bookingDate, bookingTime).isBefore(LocalDateTime.now().plusHours(1))) {
            error(resp, "Phải đặt bàn trước ít nhất 1 giờ"); return;
        }
        if (bookingTime.isBefore(LocalTime.of(10, 0)) || bookingTime.isAfter(LocalTime.of(23, 0))) {
            error(resp, "Giờ phải từ 10:00 đến 23:00"); return;
        }

        int partySize = 2;
        try { partySize = Integer.parseInt(guestsStr.trim()); } catch (Exception ignored) {}
        if (partySize < 1) partySize = 1;
        if (partySize > 200) partySize = 200;

        try {
            Booking booking = new Booking();
            booking.setCustomerName(name.trim());
            booking.setCustomerPhone(phone.replaceAll("[^+0-9]", ""));
            booking.setBookingDate(bookingDate);
            booking.setBookingTime(bookingTime);
            booking.setPartySize(partySize);
            if (note != null && !note.isBlank()
                    && !note.equalsIgnoreCase("không") && !note.equalsIgnoreCase("ko")) {
                booking.setNote(note.trim());
            }
            if (sessionUser != null) booking.setUser(sessionUser);
            bookingService.create(booking);

            // Confirmation email
            if (sessionUser != null && sessionUser.getEmail() != null && !sessionUser.getEmail().isBlank()) {
                try {
                    market.restaurant_web.service.EmailService.sendBookingConfirmation(
                        sessionUser.getEmail(), booking.getCustomerName(), booking.getBookingCode(),
                        booking.getBookingDate().toString(), booking.getBookingTime().toString(),
                        booking.getPartySize(), booking.getNote());
                } catch (Exception ignored) {}
            }

            // Dashboard badge
            Object raw = getServletContext().getAttribute("newBookingCount");
            getServletContext().setAttribute("newBookingCount", (raw instanceof Integer ? (Integer)raw : 0) + 1);

            String msg = "Đặt bàn thành công! Mã đặt bàn: " + booking.getBookingCode()
                + ". Nhà hàng sẽ xác nhận trong 30 phút. Hẹn gặp bạn ngày "
                + bookingDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                + " lúc " + booking.getBookingTime() + "! 🎉";

            resp.getWriter().write("{\"success\":true,\"bookingCode\":\""
                + booking.getBookingCode() + "\",\"message\":\"" + esc(msg) + "\"}");
        } catch (Exception e) {
            error(resp, "Lỗi tạo đặt bàn: " + e.getMessage());
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) {
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
        resp.setStatus(200);
    }

    private void error(HttpServletResponse resp, String msg) throws IOException {
        resp.getWriter().write("{\"success\":false,\"error\":\"" + esc(msg) + "\"}");
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","");
    }

    private static String extractJson(String json, String key) {
        if (json == null) return null;
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;
        idx = json.indexOf(':', idx + search.length());
        if (idx < 0) return null;
        idx++;
        while (idx < json.length() && Character.isWhitespace(json.charAt(idx))) idx++;
        if (idx >= json.length()) return null;
        if (json.charAt(idx) == '"') {
            int start = idx + 1;
            StringBuilder out = new StringBuilder();
            for (int i = start; i < json.length(); i++) {
                char c = json.charAt(i);
                if (c == '\\' && i + 1 < json.length()) {
                    char nx = json.charAt(++i);
                    if (nx == '"') out.append('"');
                    else if (nx == 'n') out.append('\n');
                    else out.append(nx);
                } else if (c == '"') break;
                else out.append(c);
            }
            return out.toString();
        }
        int end = idx;
        while (end < json.length() && ",}]".indexOf(json.charAt(end)) < 0) end++;
        String val = json.substring(idx, end).trim();
        return "null".equals(val) ? null : val;
    }
}
