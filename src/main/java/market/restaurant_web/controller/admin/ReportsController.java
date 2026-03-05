package market.restaurant_web.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/reports")
public class ReportsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Reports page - data loaded via JSP or AJAX later
        req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
    }
}
