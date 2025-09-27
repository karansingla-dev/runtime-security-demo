CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS PII (
    id SERIAL PRIMARY KEY,
    ssn VARCHAR(20),
    full_name VARCHAR(100),
    date_of_birth DATE,
    credit_card VARCHAR(20)
);

INSERT INTO users (username, email) VALUES 
    ('john_doe', 'john@example.com'),
    ('jane_smith', 'jane@example.com');

INSERT INTO PII (ssn, full_name, date_of_birth, credit_card) VALUES 
    ('123-45-6789', 'John Doe', '1990-01-01', '1234-5678-9012-3456'),
    ('987-65-4321', 'Jane Smith', '1985-05-15', '9876-5432-1098-7654');