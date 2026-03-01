package market.restaurant_web.dao;

import market.restaurant_web.entity.Product;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class ProductDAO extends GenericDAO<Product> {

    public ProductDAO() {
        super(Product.class);
    }

    // ====== SOFT DELETE ======
    public void softDelete(int id) {
        Product product = getById(id);
        if (product != null) {
            product.setStatus("UNAVAILABLE");
            update(product);
        }
    }

    // ====== SEARCH BY NAME ======
    public List<Product> searchByName(String keyword) {
        try (Session session = getSession()) {
            Query<Product> query = session.createQuery(
                    "FROM Product p WHERE p.productName LIKE :keyword", Product.class);
            query.setParameter("keyword", "%" + keyword + "%");
            return query.list();
        }
    }

    // ====== GET BY CATEGORY ======
    public List<Product> getByCategory(int categoryId) {
        try (Session session = getSession()) {
            Query<Product> query = session.createQuery(
                    "FROM Product p WHERE p.categoryId = :categoryId", Product.class);
            query.setParameter("categoryId", categoryId);
            return query.list();
        }
    }

    // ====== GET AVAILABLE PRODUCTS ======
    public List<Product> getAvailable() {
        try (Session session = getSession()) {
            Query<Product> query = session.createQuery(
                    "FROM Product p WHERE p.status = 'AVAILABLE'", Product.class);
            return query.list();
        }
    }
}
