const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
const PORT = 3000;

// Middleware agar aplikasi Flutter bisa mengakses server ini
app.use(cors());
app.use(express.json());

// Endpoint untuk mengambil data travel (Tugas 6)
// Ini mengambil data dari API publik (JSONPlaceholder) sebagai contoh
app.get("/api/travel-insights", async (req, res) => {
  try {
    const response = await axios.get(
      "https://jsonplaceholder.typicode.com/posts"
    );

    // Kita hanya ambil 5 data teratas untuk aplikasi travel kita
    const travelData = response.data.slice(0, 5).map((item) => ({
      id: item.id,
      title: `News: ${item.title}`,
      body: item.body,
    }));

    res.json(travelData);
  } catch (error) {
    res.status(500).json({ message: "Gagal mengambil data dari API publik" });
  }
});

// Jalankan server
app.listen(PORT, () => {
  console.log(`Server Trivy Backend berjalan di http://localhost:${PORT}`);
});
