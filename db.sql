CREATE TABLE users (
    userid INT AUTO_INCREMENT PRIMARY KEY,
    password TEXT NOT NULL,
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE contacts (
    contactid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    phone TEXT NOT NULL,
    companyname TEXT NOT NULL,
    address1 TEXT NOT NULL,
    address2 TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postcode TEXT NOT NULL,
    country TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE carts (
    cartid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    tag CHAR(20) NOT NULL,
    data TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE cartitems (
    cartitemid INT AUTO_INCREMENT PRIMARY KEY,
    cartid INT,
    hostingplanid INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE currencies (
    currencyid INT AUTO_INCREMENT PRIMARY KEY,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    symbol TEXT NOT NULL,
    comparetousd DECIMAL(10,4) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE domains (
    domainid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    orderid INT,
    domain TEXT NOT NULL,
    type TEXT NOT NULL,
    registrationdate DATE NOT NULL,
    expirydate DATE NOT NULL,
    status TEXT NOT NULL,
    nextduedate DATE NOT NULL,
    nextinvoicedate DATE NOT NULL,
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
    FOREIGN KEY (billingcycleid) REFERENCES billingcycles(billingcycleid),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE invoiceitems (
    invocieitemid INT AUTO_INCREMENT PRIMARY KEY,
    invoiceid INT,
    userid INT,
    description TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL,
    tax2 DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE invoices (
    invoiceid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    invoicenumber TEXT NOT NULL,
    duedate DATE NOT NULL,
    datepaid DATE NOT NULL,
    cancelleddate DATE NOT NULL,
    refunddate DATE NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    credit DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL,
    tax2 DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    taxrate DECIMAL(5,2) NOT NULL,
    taxrate2 DECIMAL(5,2) NOT NULL,
    status TEXT NOT NULL,
    paymentmethod TEXT NOT NULL,
    paymentmethodid INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    orderid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    invoiceid INT,
    hostingplanid INT,
    domainid INT,
    subtotal DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    paymentmethod TEXT NOT NULL,
    status TEXT NOT NULL,
    ipaddress TEXT NOT NULL,
    orderdata TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE userlocations (
    userlocationid INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    zipcode TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- FK definitions

ALTER TABLE contacts ADD FOREIGN KEY (userid) REFERENCES users(id);
ALTER TABLE carts ADD FOREIGN KEY (userid) REFERENCES users(id);
ALTER TABLE cartitems 
    ADD INDEX (cartid), 
    ADD INDEX (hostingplanid),
    ADD FOREIGN KEY (cartid) REFERENCES carts(id),
    ADD FOREIGN KEY (hostingplanid) REFERENCES hostingplans(id);
ALTER TABLE userlocations ADD FOREIGN KEY (userid) REFERENCES users(id);
ALTER TABLE orders 
    ADD FOREIGN KEY (userid) REFERENCES users(id),
    ADD FOREIGN KEY (invoiceid) REFERENCES invoices(id),
    ADD FOREIGN KEY (hostingplanid) REFERENCES hostingplans(id),
    ADD FOREIGN KEY (domainid) REFERENCES domains(id);
ALTER TABLE hostings 
    ADD FOREIGN KEY (userid) REFERENCES users(id),
    ADD FOREIGN KEY (orderid) REFERENCES orders(id);
ALTER TABLE invoices 
    ADD FOREIGN KEY (userid) REFERENCES users(id);
ALTER TABLE invoiceitems 
    ADD FOREIGN KEY (invoiceid) REFERENCES invoices(id),
    ADD FOREIGN KEY (userid) REFERENCES users(id);
ALTER TABLE invoicedata 
    ADD FOREIGN KEY (invoiceid) REFERENCES invoices(id);
ALTER TABLE domains 
    ADD FOREIGN KEY (userid) REFERENCES users(id),
    ADD FOREIGN KEY (orderid) REFERENCES orders(id);
ALTER TABLE hostingplanfeatures 
    ADD FOREIGN KEY (hostingplanid) REFERENCES hostingplans(id);
ALTER TABLE hostingpricing 
    ADD FOREIGN KEY (hostingplanid) REFERENCES hostingplans(id),
    ADD FOREIGN KEY (currencyid) REFERENCES currencies(id);
