'use strict';

const express = require('express');
const cors = require('cors');
const path = require('path');
const router = require('./routes/index');

const app = express();

// ── CORS & Body Parsers ─────────────────────────────────────────
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: '*',
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// ── Static Files (Uploads) ──────────────────────────────────────
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ── Root redirect ke /api/v1 ────────────────────────────────────
app.get('/', (_req, res) => {
  res.redirect('/api/v1');
});

// ── Main API Router ─────────────────────────────────────────────
app.use('/api/v1', router);

// ── Global Error Handler ────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error('[API Server Error]', err);

  const status = err.status || err.statusCode || (err.name === 'MulterError' ? 400 : 500);
  res.status(status).json({
    status: false,
    message: err.message || 'Terjadi kesalahan internal pada server.',
    data: null,
  });
});

module.exports = app;
