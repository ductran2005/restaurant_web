package market.restaurant_web.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private int productId;

    @Column(name = "category_id")
    private int categoryId;

    @Column(name = "product_name", nullable = false, length = 200)
    private String productName;

    @Column(name = "price")
    private double price;

    @Column(name = "cost_price")
    private double costPrice;

    @Column(name = "status", length = 50)
    private String status;

    @Column(name = "description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    public Product(int categoryId, String productName, double price,
            double costPrice, String status, String description) {
        this.categoryId = categoryId;
        this.productName = productName;
        this.price = price;
        this.costPrice = costPrice;
        this.status = status;
        this.description = description;
    }
}
