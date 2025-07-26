
-- User & Role Management 


CREATE TABLE user_roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE  
);
-- e.g., Customer, Brand Manager, Branch Manager, Delivery Agent
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE user_has_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (role_id) REFERENCES user_roles(id)
);

CREATE TABLE delivery_agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    is_kyc_verified BOOLEAN DEFAULT FALSE,
    current_status ENUM('offline', 'available', 'on_delivery') NOT NULL DEFAULT 'offline',
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Location & Address Data

CREATE TABLE states (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE cities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    state_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (state_id) REFERENCES states(id)
);

CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    street_address TEXT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    city_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE user_addresses (
    user_id INT NOT NULL,
    address_id INT NOT NULL,
    label VARCHAR(50) COMMENT 'e.g., Home, Work',
    PRIMARY KEY (user_id, address_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (address_id) REFERENCES addresses(id)
);

-- Restaurant (Brand/Branch), Menu & Media

CREATE TABLE restaurant_brands (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL UNIQUE COMMENT 'e.g., Pizza Hut, Domino''s Pizza',
    logo_url VARCHAR(255),
    description TEXT
);

CREATE TABLE restaurant_branches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    brand_id INT NOT NULL,
    user_id INT NOT NULL,
    address_id INT NOT NULL UNIQUE,
    branch_name VARCHAR(200) COMMENT 'Optional: e.g., Swaroop Nagar Branch',
    is_accepting_orders BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (brand_id) REFERENCES restaurant_brands(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (address_id) REFERENCES addresses(id)
);

CREATE TABLE restaurant_media (
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    media_url VARCHAR(255) NOT NULL,
    media_type ENUM('image', 'video') NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES restaurant_branches(id)
);

CREATE TABLE restaurant_timings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    week_day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES restaurant_branches(id)
);

CREATE TABLE cuisines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE brand_cuisines (
    brand_id INT NOT NULL,
    cuisine_id INT NOT NULL,
    PRIMARY KEY (brand_id, cuisine_id),
    FOREIGN KEY (brand_id) REFERENCES restaurant_brands(id),
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id)
);

CREATE TABLE branch_custom_cuisines (
    branch_id INT NOT NULL,
    cuisine_id INT NOT NULL,
    PRIMARY KEY (branch_id, cuisine_id),
    FOREIGN KEY (branch_id) REFERENCES restaurant_branches(id),
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id)
);

CREATE TABLE menu_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'e.g., Appetizers, Main Course, Desserts'
);

CREATE TABLE menu_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    is_veg BOOLEAN NOT NULL,
    image_url VARCHAR(255) NULL COMMENT 'Stores the single image URL for the item',
    FOREIGN KEY (brand_id) REFERENCES restaurant_brands(id),
    FOREIGN KEY (category_id) REFERENCES menu_categories(id)
);

CREATE TABLE branch_menu_availability (
    branch_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (branch_id, menu_item_id),
    FOREIGN KEY (branch_id) REFERENCES restaurant_branches(id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

CREATE TABLE menu_variants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    menu_item_id INT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT 'e.g., Small, Medium, Large',
    price_modifier DECIMAL(10, 2) NOT NULL COMMENT 'e.g., -1.00, 0.00, +2.50',
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- Order, Payment & Feedback

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    delivery_agent_id INT NULL,
    status ENUM('placed', 'accepted', 'preparing', 'ready', 'picked_up', 'delivered', 'cancelled') NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (branch_id) REFERENCES restaurant_branches(id),
    FOREIGN KEY (delivery_agent_id) REFERENCES delivery_agents(id)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    variant_id INT NULL,
    quantity INT NOT NULL,
    item_name VARCHAR(150) NOT NULL COMMENT 'Snapshot of item name',
    variant_name VARCHAR(100) COMMENT 'Snapshot of variant name',
    price_at_order DECIMAL(10, 2) NOT NULL COMMENT 'Snapshot of price',
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id),
    FOREIGN KEY (variant_id) REFERENCES menu_variants(id)
);

CREATE TABLE order_addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    street_address TEXT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    city_id INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('card', 'upi', 'cod') NOT NULL,
    status ENUM('pending', 'successful', 'failed') NOT NULL,
    transaction_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

CREATE TABLE ratings_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    entity_type ENUM('brand', 'branch', 'delivery_agent', 'menu_item') NOT NULL,
    entity_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);