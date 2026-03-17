package market.restaurant_web.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.OrderDetail;
import market.restaurant_web.service.OrderService;
import market.restaurant_web.service.PaymentService;

@WebServlet(urlPatterns = {"/admin/reports", "/admin/reports/export"})
public class ReportsController extends HttpServlet {
    private final OrderService orderService = new OrderService();
    private final PaymentService paymentService = new PaymentService();

    // simple DTO for revenue/orders rows
    public static class ReportRow {
        private String date;
        private long orders;
        private BigDecimal revenue;

        public ReportRow(String date, long orders, BigDecimal revenue) {
            this.date = date;
            this.orders = orders;
            this.revenue = revenue;
        }

        public String getDate() { return date; }
        public long getOrders() { return orders; }
        public BigDecimal getRevenue() { return revenue; }

        public void addOrder(BigDecimal amount) {
            this.orders++;
            this.revenue = this.revenue.add(amount == null ? BigDecimal.ZERO : amount);
        }
    }

    // DTO for top-selling items
    public static class TopItem {
        private String name;
        private long quantity;
        private BigDecimal revenue;

        public TopItem(String name, long quantity, BigDecimal revenue) {
            this.name = name;
            this.quantity = quantity;
            this.revenue = revenue;
        }

        public String getName() { return name; }
        public long getQuantity() { return quantity; }
        public BigDecimal getRevenue() { return revenue; }

        public void add(long qty, BigDecimal rev) {
            this.quantity += qty;
            this.revenue = this.revenue.add(rev == null ? BigDecimal.ZERO : rev);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // parse filter parameters
        String period = req.getParameter("period");
        if (period == null) period = "day";
        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");
        LocalDate from = LocalDate.now();
        LocalDate to = LocalDate.now();
        try {
            if (fromStr != null && !fromStr.isEmpty())
                from = LocalDate.parse(fromStr);
            if (toStr != null && !toStr.isEmpty())
                to = LocalDate.parse(toStr);
        } catch (Exception ignored) {
            // keep default if parse fails
        }
        if (from.isAfter(to)) {
            LocalDate tmp = from;
            from = to;
            to = tmp;
        }

        // load paid orders in range
        List<Order> paidOrders = paymentService.findPaidOrdersByDateRange(from, to);

        // build statistics map (maintain insertion order so dates appear sequential)
        Map<String, ReportRow> stats = new LinkedHashMap<>();
        if ("month".equals(period)) {
            YearMonth start = YearMonth.from(from);
            YearMonth end = YearMonth.from(to);
            for (YearMonth ym = start; !ym.isAfter(end); ym = ym.plusMonths(1)) {
                String label = ym.getMonthValue() + "/" + ym.getYear();
                stats.put(label, new ReportRow(label, 0, BigDecimal.ZERO));
            }
            for (Order o : paidOrders) {
                LocalDate d = o.getOpenedAt().toLocalDate();
                String key = d.getMonthValue() + "/" + d.getYear();
                ReportRow r = stats.get(key);
                if (r != null) {
                    r.addOrder(o.getTotalAmount());
                }
            }
        } else {
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                String label = d.toString();
                stats.put(label, new ReportRow(label, 0, BigDecimal.ZERO));
            }
            for (Order o : paidOrders) {
                LocalDate d = o.getOpenedAt().toLocalDate();
                String key = d.toString();
                ReportRow r = stats.get(key);
                if (r != null) {
                    r.addOrder(o.getTotalAmount());
                }
            }
        }

        List<ReportRow> revenueData = new ArrayList<>(stats.values());
        long totalOrders = revenueData.stream().mapToLong(ReportRow::getOrders).sum();
        BigDecimal totalRevenue = revenueData.stream()
                .map(ReportRow::getRevenue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // prepare chart arrays
        StringBuilder chartLabels = new StringBuilder("[");
        StringBuilder chartRevenue = new StringBuilder("[");
        StringBuilder chartOrders = new StringBuilder("[");
        boolean first = true;
        for (ReportRow r : revenueData) {
            if (!first) {
                chartLabels.append(",");
                chartRevenue.append(",");
                chartOrders.append(",");
            }
            first = false;
            chartLabels.append("\"").append(r.getDate()).append("\"");
            chartRevenue.append(r.getRevenue());
            chartOrders.append(r.getOrders());
        }
        chartLabels.append("]");
        chartRevenue.append("]");
        chartOrders.append("]");

        // compute top-selling items
        Map<String, TopItem> itemsMap = new HashMap<>();
        for (Order o : paidOrders) {
            if (o.getOrderDetails() == null) continue;
            for (OrderDetail d : o.getOrderDetails()) {
                if (!"ORDERED".equals(d.getItemStatus())) continue;
                String name = d.getProduct().getName();
                long qty = d.getQuantity();
                BigDecimal rev = d.getUnitPrice().multiply(BigDecimal.valueOf(qty));
                TopItem ti = itemsMap.get(name);
                if (ti == null) {
                    itemsMap.put(name, new TopItem(name, qty, rev));
                } else {
                    ti.add(qty, rev);
                }
            }
        }
        List<TopItem> topItems = new ArrayList<>(itemsMap.values());
        topItems.sort((a, b) -> Long.compare(b.getQuantity(), a.getQuantity()));

        // if request is for export, stream CSV (same data for XLSX link)
        String uri = req.getRequestURI();
        if (uri.endsWith("/export")) {
            String fmt = req.getParameter("format");
            boolean csv = fmt == null || fmt.equalsIgnoreCase("csv");
            String filename = "reports." + (csv ? "csv" : "xlsx");
            resp.setContentType("text/csv;charset=UTF-8");
            resp.setHeader("Content-Disposition", "attachment; filename=" + filename);
            try (java.io.PrintWriter out = resp.getWriter()) {
                out.println(csv ? "Ngày,Số đơn,Doanh thu" : "Ngày\tSố đơn\tDoanh thu");
                for (ReportRow r : revenueData) {
                    if (csv) {
                        out.printf("%s,%d,%s\n", r.getDate(), r.getOrders(), r.getRevenue());
                    } else {
                        out.printf("%s\t%d\t%s\n", r.getDate(), r.getOrders(), r.getRevenue());
                    }
                }
            }
            return;
        }

        // set attributes for JSP rendering
        req.setAttribute("revenueData", revenueData);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("chartLabels", chartLabels.toString());
        req.setAttribute("chartRevenue", chartRevenue.toString());
        req.setAttribute("chartOrders", chartOrders.toString());
        req.setAttribute("topItems", topItems);

        req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
    }
}
