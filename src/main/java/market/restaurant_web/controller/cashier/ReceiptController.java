package market.restaurant_web.controller.cashier;

import market.restaurant_web.service.ReceiptService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Controller for generating and printing receipts.
 * GET /cashier/receipt?orderId=123
 */
@WebServlet("/cashier/receipt")
public class ReceiptController extends HttpServlet {
    private final ReceiptService receiptService = new ReceiptService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId parameter");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            String receiptText = receiptService.generateReceipt(orderId);
            
            // Return as plain text for printing
            resp.setContentType("text/plain; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            
            PrintWriter out = resp.getWriter();
            out.print(receiptText);
            out.flush();
            
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid orderId format");
        } catch (RuntimeException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
