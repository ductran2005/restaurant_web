package market.restaurant_web.controller.admin;

import market.restaurant_web.service.ConfigService;
import market.restaurant_web.service.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

@WebServlet("/admin/config")
public class ConfigController extends HttpServlet {
    private final ConfigService configService = new ConfigService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Pass config as Map<key, value> so JSP can use config['smtp_user'] etc.
        Map<String, String> config = configService.getAllAsMap();
        req.setAttribute("config", config);
        req.getRequestDispatcher("/WEB-INF/views/admin/config.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String[] keys = req.getParameterValues("configKey");
            if (keys != null) {
                for (String key : keys) {
                    String value = req.getParameter("value_" + key);
                    if (value != null) {
                        // upsert: create if not exists, update if exists
                        configService.upsert(key, value.trim(), null);
                    }
                }
            }

            // Reload EmailService with new SMTP credentials from DB
            EmailService.reloadConfig(configService);

            req.getSession().setAttribute("flash_msg", "Cập nhật cấu hình thành công!");
            req.getSession().setAttribute("flash_type", "success");
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/config");
    }
}
