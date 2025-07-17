CREATE TABLE users (
    userid INT AUTO_INCREMENT PRIMARY KEY,
    password TEXT NOT NULL,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE hostingplans (
    hostingplanid INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    isactive BOOLEAN NOT NULL,
    tag TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE features (
    featureid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    featuretype VARCHAR(50) NOT NULL, -- e.g., storage, bandwidth, addon
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE currencies (
    currencyid INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE, -- e.g., USD, EUR, INR
    name VARCHAR(50) NOT NULL,
    conversionrate DECIMAL(10,4) NOT NULL, -- Conversion to USD
    symbol VARCHAR(5) NOT NULL, -- $, ₹, €
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE hostingplanfeatures (
    hostingplanfeatureid INT AUTO_INCREMENT PRIMARY KEY,
    hostingplanid INT NOT NULL,
    featureid INT NOT NULL,
    isavailable BOOLEAN NOT NULL DEFAULT TRUE,
    value VARCHAR(100) NOT NULL,
    FOREIGN KEY (hostingplanid) REFERENCES hostingplans(hostingplanid),
    FOREIGN KEY (featureid) REFERENCES features(featureid),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE hostingbillingcycles (
    hostingbillingcycleid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL, -- monthly, quarterly, annually
    months INT NOT NULL -- e.g., 1 for monthly, 3 for quarterly, etc.
);

CREATE TABLE hostingpricing (
    hostingpriceid INT AUTO_INCREMENT PRIMARY KEY,
    hostingplanid INT NOT NULL,
    currencyid INT NOT NULL,
    hostingbillingcycleid INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (hostingplanid) REFERENCES hostingplans(hostingplanid),
    FOREIGN KEY (currencyid) REFERENCES currencies(currencyid),
    FOREIGN KEY (hostingbillingcycleid) REFERENCES hostingbillingcycles(hostingbillingcycleid),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE contacts (
    contactid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    companyname Varchar(100) NOT NULL,
    address1 Varchar(256) NOT NULL,
    address2 Varchar(256) NOT NULL,
    city Varchar(100) NOT NULL,
    state Varchar(100) NOT NULL,
    postcode Varchar(100) NOT NULL,
    country Varchar(100) NOT NULL,
    FOREIGN KEY (userid) REFERENCES users(userid),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE hostingplandiscounts (
    discountid INT AUTO_INCREMENT PRIMARY KEY,
    hostingplanid INT NOT NULL,
    hostingbillingcycleid INT NOT NULL,
    discount_type ENUM('fixed', 'percentage') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    isactive BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (hostingplanid) REFERENCES hostingplans(hostingplanid),
    FOREIGN KEY (hostingbillingcycleid) REFERENCES hostingbillingcycles(hostingbillingcycleid)
);
CREATE TABLE orders (
    orderid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL,
    status ENUM('pending', 'paid', 'cancelled', 'failed', 'refunded') DEFAULT 'pending',
    total_price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    paymentmethod VARCHAR(50),
    transaction_id VARCHAR(100), -- for payment gateway reference
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userid) REFERENCES users(userid)
);
CREATE TABLE orderitems (
    orderitemid INT AUTO_INCREMENT PRIMARY KEY,
    orderid INT NOT NULL,
    item_type ENUM('hosting', 'domain', 'addon') NOT NULL,
    item_id INT NOT NULL, -- e.g., hostingplanid, domainid
    billing_cycle VARCHAR(20), -- Monthly, Annually
    base_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    final_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (orderid) REFERENCES orders(orderid)
);
