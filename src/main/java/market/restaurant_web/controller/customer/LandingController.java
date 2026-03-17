package market.restaurant_web.controller.customer;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.ProductDAO;
import market.restaurant_web.entity.Product;
import org.hibernate.Session;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Root "/" landing page controller.
 * Serves the full marketing landing page (landing.jsp).
 */
@WebServlet(urlPatterns = { "", "/" })
public class LandingController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Load featured products (first 4 available products with images)
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<Product> featuredProducts = session.createQuery(
                "FROM Product WHERE status = 'AVAILABLE' AND imageUrl IS NOT NULL " +
                "ORDER BY id DESC", Product.class)
                .setMaxResults(4)
                .list();
            
            req.setAttribute("featuredProducts", featuredProducts);
            
            // Load products for the ticker (8 products for smooth scrolling)
            List<Product> tickerProducts = session.createQuery(
                "FROM Product WHERE status = 'AVAILABLE' " +
                "ORDER BY id DESC", Product.class)
                .setMaxResults(8)
                .list();
            
            req.setAttribute("tickerProducts", tickerProducts);
        }
        
        req.getRequestDispatcher("/WEB-INF/views/public/landing.jsp").forward(req, resp);
    }
}
