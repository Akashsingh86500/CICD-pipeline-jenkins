const express = require('express')
const app = express()
const port = process.env.PORT || 3000
app.get('/health', (req, res) => res.json({ status: 'ok' }))
app.get('/orders', (req, res) => res.json([{ id: 100, total: 42 }]))
app.listen(port, '0.0.0.0')
