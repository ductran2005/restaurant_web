package market.restaurant_web.controller.admin;

import market.restaurant_web.service.*;
import market.restaurant_web.entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/admin")
public class DashboardController extends HttpServlet {
    private final OrderService orderService = new OrderService();
    private final PaymentService paymentService = new PaymentService();
    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate today = LocalDate.now();

        // KPI cards
        List<Order> todayOrders = orderService.findByDateRange(today, today);

        // Revenue from PAID orders
        List<Order> paidOrders = paymentService.findPaidOrdersByDateRange(today, today);
        BigDecimal todayRevenue = paidOrders.stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        req.setAttribute("totalOrders", todayOrders.size());
        req.setAttribute("totalRevenue", todayRevenue);
        // No bookings table - set 0
        req.setAttribute("totalBookings", 0);
        req.setAttribute("activeProducts", productService.findAvailable().size());

        // Chart data: last 7 days revenue
        StringBuilder chartLabels = new StringBuilder("[");
        StringBuilder chartData = new StringBuilder("[");
        StringBuilder chartOrders = new StringBuilder("[");
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            List<Order> dayPaid = paymentService.findPaidOrdersByDateRange(d, d);
            List<Order> dayOrders = orderService.findByDateRange(d, d);
            BigDecimal dayRev = dayPaid.stream()
                    .map(Order::getTotalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            if (i < 6) {
                chartLabels.append(",");
                chartData.append(",");
                chartOrders.append(",");
            }
            chartLabels.append("\"").append(d.getDayOfMonth()).append("/").append(d.getMonthValue()).append("\"");
            chartData.append(dayRev);
            chartOrders.append(dayOrders.size());
        }
        chartLabels.append("]");
        chartData.append("]");
        chartOrders.append("]");

        req.setAttribute("chartLabels", chartLabels.toString());
        req.setAttribute("chartRevenue", chartData.toString());
        req.setAttribute("chartOrders", chartOrders.toString());

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
