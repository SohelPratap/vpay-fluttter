const express = require('express');
const mysql = require('mysql2');  // Use mysql2 package
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Mysql@135',
    database: 'vpay'
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        process.exit(1);
    }
    console.log('Connected to MySQL database!');
});

// Route to save profile
app.post('/save-profile', (req, res) => {
    const { phoneNumber, name, email } = req.body;

    if (!phoneNumber || !name) {
        return res.status(400).json({ error: 'Phone number and name are required.' });
    }

    const query = `INSERT INTO profiles (phone_number, name, email)
                   VALUES (?, ?, ?)
                   ON DUPLICATE KEY UPDATE name = VALUES(name), email = VALUES(email)`;

    db.query(query, [phoneNumber, name, email], (err, result) => {
        if (err) {
            console.error('Error saving profile:', err);
            return res.status(500).json({ error: 'Failed to save profile.' });
        }

        // After saving the profile, update the auth field to 'yes'
        const updateAuthQuery = `UPDATE profiles SET auth = 'yes' WHERE phone_number = ?`;

        db.query(updateAuthQuery, [phoneNumber], (err, result) => {
            if (err) {
                console.error('Error updating auth:', err);
                return res.status(500).json({ error: 'Failed to update authentication.' });
            }

            res.status(200).json({ message: 'Profile saved and authenticated successfully!' });
        });
    });
});

// Start the server on all network interfaces
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});