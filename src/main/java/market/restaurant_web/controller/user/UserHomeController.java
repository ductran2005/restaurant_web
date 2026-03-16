package market.restaurant_web.controller.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * User dashboard — /user/home
 * Shows welcome message and quick-action cards.
 */
@WebServlet("/user/home")
public class UserHomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("navActive", "home");
        req.getRequestDispatcher("/WEB-INF/views/user/home.jsp").forward(req, resp);
    }
}
