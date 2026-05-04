// const express = require('express'); // 1. Express ko import kiya
// const cors = require('cors');        // 2. CORS ko import kiya
// require('dotenv').config();

// const app = express(); // <--- YEH LINE MISSING THI (Isse 'app' banta hai)

// // Middleware
// app.use(cors()); 
// app.use(express.json()); 

// // --- ROUTES ---

// // 1. Home Route (Check karne ke liye)
// app.get('/', (req, res) => {
//     res.send("Echoo Backend is LIVE! 🚀");
// });

// // 2. Login API Endpoint (Jo humne abhi banaya)
// app.post('/api/login', (req, res) => {
//     const { phoneNumber } = req.body;
//     console.log("Login attempt for:", phoneNumber);

//     if (!phoneNumber) {
//         return res.status(400).json({ 
//             success: false, 
//             message: "Phone number zaroori hai!" 
//         });
//     }

//     res.status(200).json({
//         success: true,
//         message: "Login successful!",
//         user: { id: "123", phone: phoneNumber },
//         token: "fake-jwt-token-abcd"
//     });
// });

// // Port setup
// const PORT = 3000;
// app.listen(PORT, () => {
//     console.log(`Server is running on http://localhost:${PORT}`);
// });

// 1. Express Import aur Initialize karein
const express = require('express');
const app = express();

// 2. Middleware (Flutter se aane wale JSON data ko padhne ke liye yeh bahut zaroori hai)
app.use(express.json());

// 3. Aapka API Route
app.post('/api/login', (req, res) => {
    console.log("Request Aayi Hai! Data:", req.body); // Terminal mein data print hoga
    res.status(200).send({ message: "Success" });    // Flutter ko 'Success' bheja jayega
});

// 4. Server Start Karein
const PORT = 3000; // Aap port 3000 ya 8000 kuch bhi rakh sakte hain
app.listen(PORT, () => {
    console.log(`Backend Server is running perfectly on port ${PORT} ✅`);
});
