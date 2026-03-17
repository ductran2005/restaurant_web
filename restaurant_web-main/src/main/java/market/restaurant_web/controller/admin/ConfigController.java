package market.restaurant_web.controller.admin;

import market.restaurant_web.service.ConfigService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/config")
public class ConfigController extends HttpServlet {
    private final ConfigService configService = new ConfigService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("configs", configService.findAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/config.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Map<String, String> updates = new HashMap<>();
            String[] keys = req.getParameterValues("configKey");
            if (keys != null) {
                for (String key : keys) {
                    String value = req.getParameter("value_" + key);
                    if (value != null) {
                        updates.put(key, value.trim());
                    }
                }
            }
            configService.updateAll(updates);
            req.getSession().setAttribute("flash_msg", "Cập nhật cấu hình thành công!");
            req.getSession().setAttribute("flash_type", "success");
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/config");
    }
}
