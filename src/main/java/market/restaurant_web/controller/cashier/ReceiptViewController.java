package market.restaurant_web.controller.cashier;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Controller for displaying receipt view page.
 * GET /cashier/receipt/view?orderId=123
 */
@WebServlet("/cashier/receipt/view")
public class ReceiptViewController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId parameter");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/cashier/receipt.jsp")
            .forward(req, resp);
    }
}
