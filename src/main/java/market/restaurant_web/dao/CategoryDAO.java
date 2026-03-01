package market.restaurant_web.dao;

import market.restaurant_web.entity.Category;

public class CategoryDAO extends GenericDAO<Category> {

    public CategoryDAO() {
        super(Category.class);
    }
}
