const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const DB_PATH = path.join(__dirname, 'db.json');
function readDB() {
  try { return JSON.parse(fs.readFileSync(DB_PATH, 'utf8')); }
  catch { return { products: [], orders: [], customers: [], deliveries: [] }; }
}
function writeDB(data) { fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2)); }

// ============================================
// PRODUITS — Catalogue discret
// ============================================
app.get('/api/products', (req, res) => {
  const db = readDB();
  const { category, search } = req.query;
  let products = db.products || [];
  if (category) products = products.filter(p => p.category === category);
  if (search) products = products.filter(p => 
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    p.description.toLowerCase().includes(search.toLowerCase())
  );
  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const db = readDB();
  const product = db.products.find(p => p.id === Number(req.params.id));
  product ? res.json(product) : res.status(404).json({ error: 'Produit non trouvé' });
});

app.post('/api/products', (req, res) => {
  const db = readDB();
  const product = { 
    id: Date.now(), 
    ...req.body, 
    createdAt: new Date().toISOString(),
    status: 'active'
  };
  db.products.push(product);
  writeDB(db);
  res.status(201).json(product);
});

app.put('/api/products/:id', (req, res) => {
  const db = readDB();
  const idx = db.products.findIndex(p => p.id === Number(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'Produit non trouvé' });
  db.products[idx] = { ...db.products[idx], ...req.body };
  writeDB(db);
  res.json(db.products[idx]);
});

app.delete('/api/products/:id', (req, res) => {
  const db = readDB();
  db.products = db.products.filter(p => p.id !== Number(req.params.id));
  writeDB(db);
  res.json({ success: true });
});

// ============================================
// CATEGORIES
// ============================================
app.get('/api/categories', (req, res) => {
  const db = readDB();
  const categories = [...new Set(db.products.map(p => p.category))];
  res.json(categories.map(c => ({ 
    id: c, 
    name: c.charAt(0).toUpperCase() + c.slice(1).replace('-', ' '),
    count: db.products.filter(p => p.category === c).length
  })));
});

// ============================================
// COMMANDES — Avec livraison anonyme
// ============================================
app.get('/api/orders', (req, res) => {
  const db = readDB();
  const { status, customer_id } = req.query;
  let orders = db.orders || [];
  if (status) orders = orders.filter(o => o.status === status);
  if (customer_id) orders = orders.filter(o => o.customer_id === Number(customer_id));
  res.json(orders);
});

app.get('/api/orders/:id', (req, res) => {
  const db = readDB();
  const order = db.orders.find(o => o.id === Number(req.params.id));
  if (!order) return res.status(404).json({ error: 'Commande non trouvée' });
  
  // Enrichir avec les détails produits
  const items = order.items.map(item => {
    const product = db.products.find(p => p.id === item.product_id);
    return { ...item, product };
  });
  res.json({ ...order, items });
});

app.post('/api/orders', (req, res) => {
  const db = readDB();
  const { customer_id, items, delivery_method, delivery_address, customer_name, customer_phone } = req.body;
  
  if (!items || items.length === 0) {
    return res.status(400).json({ error: 'Panier vide' });
  }

  // Calculer le total et vérifier le stock
  let total = 0;
  const orderItems = [];
  for (const item of items) {
    const product = db.products.find(p => p.id === item.product_id);
    if (!product) return res.status(400).json({ error: `Produit ${item.product_id} non trouvé` });
    if (product.stock < item.qty) return res.status(400).json({ error: `Stock insuffisant pour ${product.name}` });
    
    const itemTotal = product.price * item.qty;
    total += itemTotal;
    orderItems.push({
      product_id: product.id,
      product_name: product.name,
      qty: item.qty,
      unit_price: product.price,
      total: itemTotal
    });
  }

  // Frais de livraison (gratuit si > 20k)
  const delivery_fee = total >= 20000 ? 0 : 2500;
  total += delivery_fee;

  const order = {
    id: Date.now(),
    customer_id: customer_id || null,
    customer_name: customer_name || 'Anonyme',
    customer_phone: customer_phone || null,
    items: orderItems,
    subtotal: total - delivery_fee,
    delivery_fee,
    total,
    status: 'pending', // pending, confirmed, shipped, delivered, cancelled
    delivery_method: delivery_method || 'delivery', // delivery, click-collect
    delivery_address: delivery_address || null,
    anonymous_packaging: true,
    notes: req.body.notes || '',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  db.orders.push(order);

  // Décrémenter le stock
  for (const item of items) {
    const product = db.products.find(p => p.id === item.product_id);
    product.stock -= item.qty;
  }

  writeDB(db);
  res.status(201).json(order);
});

app.put('/api/orders/:id/status', (req, res) => {
  const db = readDB();
  const order = db.orders.find(o => o.id === Number(req.params.id));
  if (!order) return res.status(404).json({ error: 'Commande non trouvée' });
  
  const { status } = req.body;
  order.status = status;
  order.updated_at = new Date().toISOString();
  writeDB(db);
  res.json(order);
});

// ============================================
// LIVRAISON — Suivi discret
// ============================================
app.get('/api/deliveries', (req, res) => {
  const db = readDB();
  const deliveries = db.orders
    .filter(o => o.delivery_method === 'delivery' && o.status !== 'pending')
    .map(o => ({
      order_id: o.id,
      customer_name: o.customer_name,
      address: o.delivery_address,
      status: o.status,
      anonymous_code: `ENIG${String(o.id).slice(-4)}`,
      created_at: o.created_at
    }));
  res.json(deliveries);
});

// ============================================
// CLIENTS — Gestion minimale (discrétion)
// ============================================
app.get('/api/customers', (req, res) => {
  const db = readDB();
  // Retourner uniquement les données non-sensibles
  const customers = db.customers.map(c => ({
    id: c.id,
    name: c.name,
    phone: c.phone.replace(/(\d{2})(\d{2})(\d{3})(\d{2})(\d{2})/, '$1**$3$4$5'), // Masquer téléphone
    verified: c.verified,
    orders_count: db.orders.filter(o => o.customer_id === c.id).length
  }));
  res.json(customers);
});

// ============================================
// AUTH — Login minimal (phone only)
// ============================================
app.post('/api/auth/login', (req, res) => {
  const db = readDB();
  const { phone } = req.body;
  let customer = db.customers.find(c => c.phone === phone);
  if (!customer) {
    customer = { id: Date.now(), name: `Client #${Date.now()}`, phone, verified: false };
    db.customers.push(customer);
    writeDB(db);
  }
  res.json({ 
    token: `fake-jwt-${customer.id}`, 
    customer: { id: customer.id, name: customer.name, phone: customer.phone.replace(/(\d{2})(\d{2})(\d{3})(\d{2})(\d{2})/, '$1**$3$4$5') }
  });
});

// ============================================
// STATISTIQUES
// ============================================
app.get('/api/stats', (req, res) => {
  const db = readDB();
  const orders = db.orders || [];
  const products = db.products || [];
  const customers = db.customers || [];
  
  const totalRevenue = orders.reduce((s, o) => s + (o.total || 0), 0);
  const pendingOrders = orders.filter(o => o.status === 'pending').length;
  const deliveredOrders = orders.filter(o => o.status === 'delivered').length;
  const avgOrderValue = orders.length > 0 ? Math.round(totalRevenue / orders.length) : 0;

  res.json({
    products: products.length,
    orders: orders.length,
    customers: customers.length,
    revenue: totalRevenue,
    pending_orders: pendingOrders,
    delivered_orders: deliveredOrders,
    avg_order_value: avgOrderValue,
    low_stock: products.filter(p => p.stock < 5).length
  });
});

// ============================================
// HEALTH
// ============================================
app.get('/api/health', (req, res) => res.json({ status: 'ok', service: 'enigme', version: '1.0.0' }));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`
  ╔═══════════════════════════════════════════════╗
  ║  🔞 L'Énigme — Backend E-commerce           ║
  ║  Port: ${PORT}                                ║
  ║  API: http://localhost:${PORT}/api            ║
  ╚═══════════════════════════════════════════════╝
  `);
});
