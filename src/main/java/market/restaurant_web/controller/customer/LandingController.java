package market.restaurant_web.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Root "/" landing page controller.
 * Serves the full marketing landing page (landing.jsp).
 */
@WebServlet(urlPatterns = { "", "/" })
public class LandingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/customer/landing.jsp").forward(req, resp);
    }
}
