package market.restaurant_web.service;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * Email service for sending booking confirmation emails.
 * Uses Gmail SMTP with App Password for authentication.
 *
 * Setup instructions:
 * 1. Enable 2-Step Verification on your Google Account
 * 2. Generate an App Password: https://myaccount.google.com/apppasswords
 * 3. Update SMTP_USER and SMTP_PASS below with your credentials
 */
public class EmailService {

    // ═══ SMTP Configuration ═══
    // Replace with your Gmail and App Password
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;
    private static final String SMTP_USER = "ductest2310@gmail.com";
    private static final String SMTP_PASS = "vebi jwiy zuhd nujz";
    private static final String FROM_NAME = "Nhà hàng Hương Việt";

    private static Session mailSession;

    /** Get or create mail session (lazy singleton) */
    private static Session getMailSession() {
        if (mailSession == null) {
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", String.valueOf(SMTP_PORT));
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            props.put("mail.smtp.connectiontimeout", "10000");
            props.put("mail.smtp.timeout", "10000");
            props.put("mail.smtp.writetimeout", "10000");

            mailSession = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                }
            });
        }
        return mailSession;
    }

    /**
     * Send booking confirmation email.
     * Runs in a new thread to avoid blocking the HTTP request.
     */
    public static void sendBookingConfirmation(String toEmail, String customerName,
            String bookingCode, String bookingDate, String bookingTime,
            int partySize, String note) {

        // Run email sending in background thread
        new Thread(() -> {
            try {
                String subject = "✅ Xác nhận đặt bàn " + bookingCode + " — Nhà hàng Hương Việt";
                String htmlBody = buildBookingConfirmationHtml(
                        customerName, bookingCode, bookingDate, bookingTime, partySize, note);

                sendHtmlEmail(toEmail, subject, htmlBody);
                System.out.println("[EMAIL] ✓ Sent booking confirmation to " + toEmail + " for " + bookingCode);
            } catch (Exception e) {
                System.err.println("[EMAIL] ✗ Failed to send email to " + toEmail + ": " + e.getMessage());
                e.printStackTrace();
            }
        }).start();
    }

    /** Send an HTML email */
    private static void sendHtmlEmail(String to, String subject, String htmlBody) throws MessagingException, java.io.UnsupportedEncodingException {
        MimeMessage message = new MimeMessage(getMailSession());
        message.setFrom(new InternetAddress(SMTP_USER, FROM_NAME, "UTF-8"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject, "UTF-8");
        message.setContent(htmlBody, "text/html; charset=UTF-8");
        message.setSentDate(new java.util.Date());

        Transport.send(message);
    }

    /** Build beautiful HTML email template for booking confirmation */
    private static String buildBookingConfirmationHtml(String customerName, String bookingCode,
            String bookingDate, String bookingTime, int partySize, String note) {

        String noteSection = (note != null && !note.isBlank())
                ? "<tr><td style=\"padding:12px 20px;color:#9e9488;font-size:13px;border-top:1px solid #2a2520\">"
                  + "<strong style=\"color:#f0ebe3\">Ghi chú:</strong> " + escapeHtml(note) + "</td></tr>"
                : "";

        return "<!DOCTYPE html>"
            + "<html lang=\"vi\">"
            + "<head><meta charset=\"UTF-8\"></head>"
            + "<body style=\"margin:0;padding:0;background:#0f0e0c;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif\">"
            + "<div style=\"max-width:560px;margin:0 auto;padding:20px\">"

            // Header
            + "<div style=\"background:linear-gradient(135deg,#1a1814,#232019);border:1px solid rgba(232,160,32,0.2);border-radius:16px 16px 0 0;padding:32px 24px;text-align:center\">"
            + "<div style=\"width:48px;height:48px;background:#e8a020;border-radius:12px;display:inline-flex;align-items:center;justify-content:center;margin-bottom:12px\">"
            + "<span style=\"font-size:22px\">🍽️</span></div>"
            + "<h1 style=\"color:#f0ebe3;font-size:22px;margin:0 0 4px\">Nhà hàng Hương Việt</h1>"
            + "<p style=\"color:#9e9488;font-size:12px;margin:0;letter-spacing:1px\">NHÀ HÀNG & QUÁN NHẬU</p>"
            + "</div>"

            // Success banner
            + "<div style=\"background:rgba(34,197,94,0.08);border-left:1px solid rgba(232,160,32,0.2);border-right:1px solid rgba(232,160,32,0.2);padding:20px 24px;text-align:center\">"
            + "<div style=\"font-size:32px;margin-bottom:8px\">✅</div>"
            + "<h2 style=\"color:#4ade80;font-size:18px;margin:0 0 4px\">Đặt bàn thành công!</h2>"
            + "<p style=\"color:#9e9488;font-size:13px;margin:0\">Chúng tôi đã nhận được yêu cầu đặt bàn của bạn</p>"
            + "</div>"

            // Booking details
            + "<div style=\"background:#1a1814;border-left:1px solid rgba(232,160,32,0.2);border-right:1px solid rgba(232,160,32,0.2);padding:0\">"
            + "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-collapse:collapse\">"

            // Booking code
            + "<tr><td style=\"padding:16px 20px;text-align:center;border-bottom:1px solid #2a2520\">"
            + "<p style=\"color:#9e9488;font-size:11px;margin:0 0 4px;text-transform:uppercase;letter-spacing:1px\">Mã đặt bàn</p>"
            + "<p style=\"color:#e8a020;font-size:24px;font-weight:800;margin:0;letter-spacing:2px\">" + escapeHtml(bookingCode) + "</p>"
            + "</td></tr>"

            // Customer name
            + "<tr><td style=\"padding:12px 20px;border-bottom:1px solid #2a2520\">"
            + "<table width=\"100%\"><tr>"
            + "<td style=\"color:#9e9488;font-size:13px\">👤 Khách hàng</td>"
            + "<td style=\"color:#f0ebe3;font-size:14px;font-weight:600;text-align:right\">" + escapeHtml(customerName) + "</td>"
            + "</tr></table></td></tr>"

            // Date
            + "<tr><td style=\"padding:12px 20px;border-bottom:1px solid #2a2520\">"
            + "<table width=\"100%\"><tr>"
            + "<td style=\"color:#9e9488;font-size:13px\">📅 Ngày</td>"
            + "<td style=\"color:#f0ebe3;font-size:14px;font-weight:600;text-align:right\">" + escapeHtml(bookingDate) + "</td>"
            + "</tr></table></td></tr>"

            // Time
            + "<tr><td style=\"padding:12px 20px;border-bottom:1px solid #2a2520\">"
            + "<table width=\"100%\"><tr>"
            + "<td style=\"color:#9e9488;font-size:13px\">🕐 Giờ</td>"
            + "<td style=\"color:#f0ebe3;font-size:14px;font-weight:600;text-align:right\">" + escapeHtml(bookingTime) + "</td>"
            + "</tr></table></td></tr>"

            // Party size
            + "<tr><td style=\"padding:12px 20px;border-bottom:1px solid #2a2520\">"
            + "<table width=\"100%\"><tr>"
            + "<td style=\"color:#9e9488;font-size:13px\">👥 Số khách</td>"
            + "<td style=\"color:#f0ebe3;font-size:14px;font-weight:600;text-align:right\">" + partySize + " người</td>"
            + "</tr></table></td></tr>"

            // Note (optional)
            + noteSection

            + "</table></div>"

            // Pre-order CTA
            + "<div style=\"background:#232019;border-left:1px solid rgba(232,160,32,0.2);border-right:1px solid rgba(232,160,32,0.2);padding:20px 24px;text-align:center\">"
            + "<p style=\"color:#f0ebe3;font-size:14px;font-weight:600;margin:0 0 8px\">🛒 Đặt món trước để tiết kiệm thời gian!</p>"
            + "<p style=\"color:#9e9488;font-size:12px;margin:0 0 16px\">Chọn sẵn món ăn, chúng tôi sẽ chuẩn bị khi bạn đến</p>"
            + "<a href=\"#\" style=\"display:inline-block;padding:12px 28px;background:#e8a020;color:#000;font-size:14px;font-weight:700;border-radius:8px;text-decoration:none\">"
            + "Đặt món trước →</a>"
            + "</div>"

            // Footer notes
            + "<div style=\"background:#1a1814;border:1px solid rgba(232,160,32,0.2);border-top:none;border-radius:0 0 16px 16px;padding:20px 24px\">"
            + "<p style=\"color:#e8a020;font-size:12px;font-weight:700;margin:0 0 8px\">📌 Lưu ý quan trọng:</p>"
            + "<ul style=\"color:#9e9488;font-size:12px;margin:0;padding-left:16px;line-height:1.8\">"
            + "<li>Vui lòng đến đúng giờ. Chúng tôi giữ bàn <strong style=\"color:#f0ebe3\">20 phút</strong> kể từ giờ đặt</li>"
            + "<li>Nếu cần hủy, vui lòng báo trước ít nhất <strong style=\"color:#f0ebe3\">1 giờ</strong></li>"
            + "<li>Tra cứu / hủy booking trên website với mã <strong style=\"color:#e8a020\">" + escapeHtml(bookingCode) + "</strong></li>"
            + "</ul>"
            + "</div>"

            // Bottom footer
            + "<div style=\"text-align:center;padding:24px 16px\">"
            + "<p style=\"color:#9e9488;font-size:12px;margin:0 0 4px\">📍 123 Nguyễn Huệ, Q.1, TP.HCM</p>"
            + "<p style=\"color:#9e9488;font-size:12px;margin:0 0 4px\">📞 Hotline: <strong style=\"color:#e8a020\">1900 1234</strong> (8:00 – 23:00)</p>"
            + "<p style=\"color:#666;font-size:11px;margin:12px 0 0\">© 2026 Nhà hàng Hương Việt. All rights reserved.</p>"
            + "</div>"

            + "</div>"
            + "</body></html>";
    }

    /** Simple HTML escaping */
    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;");
    }
}
