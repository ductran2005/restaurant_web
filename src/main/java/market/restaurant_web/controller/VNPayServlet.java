package market.restaurant_web.controller;

import market.restaurant_web.utils.VNPayConfig;
import market.restaurant_web.service.PaymentService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.math.BigDecimal;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * VNPay Payment Servlet.
 * POST /vnpay-pay → tạo URL thanh toán VNPay và redirect
 * GET /vnpay-return → nhận callback từ VNPay, xử lý kết quả
 * (Migrated from D:\game\restaurant-ipos-java)
 */
// Servlet registered in web.xml: /vnpay-pay, /vnpay-return
public class VNPayServlet extends BaseServlet {

    private static final Logger LOG = Logger.getLogger(VNPayServlet.class.getName());
    private final PaymentService paymentService = new PaymentService();

    /**
     * POST /vnpay-pay — Tạo URL thanh toán VNPay và redirect user đến trang VNPay.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            long amount = Long.parseLong(req.getParameter("amount")) * 100; // VNPay yêu cầu x100

            // Lấy cashierId từ session
            Integer cashierId = null;
            market.restaurant_web.entity.User user = getCurrentUser(req);
            if (user != null) {
                cashierId = user.getUserId();
            }
            if (cashierId == null)
                cashierId = 1;

            String vnp_TxnRef = VNPayConfig.getRandomNumber(8);
            String vnp_IpAddr = VNPayConfig.getIpAddress(req);

            // Lưu vào session để callback sử dụng
            req.getSession().setAttribute("vnpayOrderId", orderId);
            req.getSession().setAttribute("vnpayCashierId", cashierId);

            // Tạo params
            Map<String, String> vnp_Params = new HashMap<>();
            vnp_Params.put("vnp_Version", "2.1.0");
            vnp_Params.put("vnp_Command", "pay");
            vnp_Params.put("vnp_TmnCode", VNPayConfig.vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amount));
            vnp_Params.put("vnp_CurrCode", "VND");
            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang:" + vnp_TxnRef);
            vnp_Params.put("vnp_OrderType", "other");
            vnp_Params.put("vnp_Locale", "vn");
            // Return URL động theo context path thực tế
            String returnUrl = req.getScheme() + "://" + req.getServerName()
                    + ":" + req.getServerPort() + req.getContextPath() + "/vnpay-return";
            vnp_Params.put("vnp_ReturnUrl", returnUrl);
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));
            cld.add(Calendar.MINUTE, 15);
            vnp_Params.put("vnp_ExpireDate", formatter.format(cld.getTime()));

            // Build query string + hash
            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();
            Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                    query.append('=');
                    query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }
            String queryUrl = query.toString();
            String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.secretKey, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;

            resp.sendRedirect(paymentUrl);

        } catch (Exception e) {
            LOG.log(Level.SEVERE, "VNPay error", e);
            throw new ServletException("Lỗi tạo thanh toán VNPay", e);
        }
    }

    /**
     * GET /vnpay-return — VNPay callback sau khi user thanh toán xong.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            // Lấy tất cả params từ VNPay — encode VALUE để match hash
            Map<String, String> fields = new HashMap<>();
            Enumeration<String> params = req.getParameterNames();
            while (params.hasMoreElements()) {
                String fieldName = params.nextElement();
                String fieldValue = req.getParameter(fieldName);
                if (fieldValue != null && fieldValue.length() > 0) {
                    fields.put(fieldName,
                            URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                }
            }

            String vnp_SecureHash = req.getParameter("vnp_SecureHash");
            fields.remove("vnp_SecureHashType");
            fields.remove("vnp_SecureHash");

            // Hash lại fields để xác thực
            String signValue = VNPayConfig.hashAllFields(fields);

            String vnp_ResponseCode = req.getParameter("vnp_ResponseCode");
            String vnp_Amount = req.getParameter("vnp_Amount");
            Integer orderId = (Integer) req.getSession().getAttribute("vnpayOrderId");

            LOG.info("VNPay return: responseCode=" + vnp_ResponseCode
                    + ", orderId=" + orderId + ", amount=" + vnp_Amount);
            LOG.info("Hash match: " + signValue.equals(vnp_SecureHash));

            if (signValue.equals(vnp_SecureHash)) {
                if ("00".equals(vnp_ResponseCode) && orderId != null) {
                    // Thanh toán thành công từ VNPay
                    try {
                        long amountVnd = Long.parseLong(vnp_Amount) / 100;
                        Integer cashierId = (Integer) req.getSession().getAttribute("vnpayCashierId");
                        if (cashierId == null)
                            cashierId = 1;

                        boolean ok = paymentService.processPayment(
                                orderId, new BigDecimal(amountVnd),
                                "VNPAY", cashierId);

                        if (ok) {
                            LOG.info("VNPay payment SUCCESS for order #" + orderId);
                        } else {
                            LOG.warning("VNPay processPayment returned false for order #" + orderId);
                        }
                    } catch (Exception e) {
                        LOG.log(Level.SEVERE, "VNPay processPayment error for order #" + orderId, e);
                    }
                    resp.sendRedirect(req.getContextPath()
                            + "/checkout?view=receipt&orderId=" + orderId);
                } else {
                    req.setAttribute("error",
                            "Thanh toán thất bại (Mã: " + vnp_ResponseCode + ")");
                    req.setAttribute("orderId", orderId);
                    req.getRequestDispatcher("/WEB-INF/views/vnpay-result.jsp").forward(req, resp);
                }
            } else {
                LOG.warning("VNPay hash mismatch! expected=" + signValue + " got=" + vnp_SecureHash);
                req.setAttribute("error", "Chữ ký không hợp lệ!");
                req.getRequestDispatcher("/WEB-INF/views/vnpay-result.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "VNPay return error", e);
            throw new ServletException("Lỗi xử lý VNPay", e);
        }
    }
}
