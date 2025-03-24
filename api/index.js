require('dotenv').config({ path: '../assets/.env' });
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
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

// Route to check if user exists and their authentication status
app.get('/check-auth/:phoneNumber', (req, res) => {
    const phoneNumber = req.params.phoneNumber;

    const query = `SELECT * FROM profiles WHERE phone_number = ?`;

    db.query(query, [phoneNumber], (err, results) => {
        if (err) {
            console.error('Error checking user authentication:', err);
            return res.status(500).json({ error: 'Failed to check authentication status' });
        }

        if (results.length > 0) {
            res.status(200).json({ auth: results[0].auth });
        } else {
            res.status(404).json({ error: 'User not found' });
        }
    });
});

// Route to fetch user profile details based on phone number
app.get('/fetch-profile/:phoneNumber', (req, res) => {
    const phoneNumber = decodeURIComponent(req.params.phoneNumber);

    const query = `SELECT phone_number, name, email FROM profiles WHERE phone_number = ?`;

    db.query(query, [phoneNumber], (err, results) => {
        if (err) {
            console.error('Error fetching user profile:', err);
            return res.status(500).json({ error: 'Failed to fetch profile' });
        }

        if (results.length > 0) {
            const user = results[0];
            res.status(200).json({ phoneNumber: user.phone_number, name: user.name, email: user.email });
        } else {
            res.status(404).json({ error: 'User not found' });
        }
    });
});

// Route to analyze voice transcript using Mistral AI
app.post('/analyze-transcript', async (req, res) => {
    try {
        const { transcript } = req.body;
        if (!transcript) return res.status(400).json({ error: "Transcript is required" });

        const prompt = `STRICTLY respond in this JSON format:
        {
          "intent": "make_payment|check_balance|check_history",
          "parameters": {
            "name": "(string)",
            "amount": (number)
          },
          "clarification_message": "(string)"
        }

        Examples:
        1. Command: "Send ₹500 to Ravi"
        Response: {"intent":"make_payment","parameters":{"name":"Ravi","amount":500},"clarification_message":""}

        2. Command: "Check balance"
        Response: {"intent":"check_balance","parameters":{"name":"","amount":""},"clarification_message":""}

        3. Command: "Wire money to colleague"
        Response: {"intent":"make_payment","parameters":{"name":"colleague","amount":""},"clarification_message":"How much would you like to send to colleague?"}

        Now process: ${transcript}`;

        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${process.env.OPENROUTER_API_KEY}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                "model": "mistralai/mistral-small-3.1-24b-instruct:free",
                "messages": [{ role: "user", content: [{ "type": "text", "text": prompt }] }],
                "temperature": 0,
                "max_tokens": 200
            })
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error(`API request failed: ${errorText}`);
            return res.status(response.status).json({ error: "Failed to fetch AI response" });
        }

        const data = await response.json();
        if (!data.choices || data.choices.length === 0 || !data.choices[0].message) {
            return res.status(500).json({ error: "Invalid response format from AI" });
        }

        const aiResult = data.choices[0].message.content.trim().replace(/```json|```/g, "");
        let parsedResult;
        try {
            parsedResult = JSON.parse(aiResult);
        } catch (parseError) {
            console.error("JSON Parsing Error:", parseError, "AI Response:", aiResult);
            return res.status(500).json({ error: "Invalid AI response format" });
        }

        res.json(parsedResult);
    } catch (error) {
        console.error("AI Analysis Error:", error);
        res.status(500).json({ error: "Failed to fetch AI analysis" });
    }
});

// Start the server on all network interfaces
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});
