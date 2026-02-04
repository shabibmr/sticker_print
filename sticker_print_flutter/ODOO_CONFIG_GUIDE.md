# Odoo Configuration Guide

## ✅ Connection Test Results

**Authentication:** ✅ Successful (User ID: 62)  
**API Key:** Working perfectly  
**CORS:** ✅ No issues - Direct HTTP from Flutter!

---

## 📋 Available Models in Your Odoo Instance

Based on the discovery test, here are the models available:

| Model | Records Found | Sample |
|-------|---------------|---------|
| `sale.order` | ✅ 100 | DM/QTR/2026/QN-28449 |
| `stock.picking` | ✅ 100 | WH/OUT/00009 |
| `mrp.production` | ✅ 0 | (Manufacturing Orders) |
| `mrp.workorder` | ✅ 0 | (Work Orders) |

**Not Available:**
- ❌ `project.project` (original default)
- ❌ `quality.check`
- ❌ `quality.certificate`
- ❌ `project.task`

---

## 🔧 Recommended Configuration

Since `quality.certificate` is not available, you'll need to determine which model stores your certificate/label data. Here are the most likely options:

### Option 1: Use Sale Orders
If certificates are linked to sales orders:
```
Job Order Model: sale.order
Certificate Model: sale.order.line (or custom model)
Relation Field: order_id
```

### Option 2: Use Manufacturing
If you're in manufacturing/quality control:
```
Job Order Model: mrp.production
Certificate Model: stock.move.line (or custom model)
Relation Field: raw_material_production_id
```

### Option 3: Custom Model
You may have a custom quality/certificate model installed. Check your Odoo interface under:
- Quality → Certificates
- Inventory → Quality
- Manufacturing → Quality Control

---

## 🎯 How to Configure in the App

1. **Open Settings** (⚙️ icon in the app)

2. **Connection Tab:**
   - URL: `https://test2.graycodeanalytica.com`
   - Database: `run.qatar.dimemarine.com.001`
   - Username: `api_user@dimemarine.com`
   - Password: `1ddf392b3daf7b0344cb7a82c9b2dc43a4dc5004`
   - ✅ Test Connection

3. **Models Tab:**
   - Job Order Model: `sale.order` (or your actual model)
   - Certificate Model: `[your certificate model]`
   - Link Field: `order_id` (or your field)

4. **Fields Tab:**
   - Serial Number Field: `slno` (or actual field name)
   - Certificate No Field: `certificate_number`
   - Issue Date Field: `issue_date`
   - Expiry Date Field: `expiry_date`

---

## 🔍 How to Find Your Certificate Model

### Method 1: Check Odoo Web Interface
1. Log into Odoo web interface
2. Go to the module where you manage certificates/labels
3. Look at the URL when viewing a certificate
   - Example: `/web#model=quality.certificate&id=123`
   - The model name is shown in the URL

### Method 2: Ask Your Odoo Administrator
They can tell you:
- What model stores certificate data
- What fields exist on that model
- How it relates to job orders/projects

### Method 3: Test with the App
1. Enter a model name in Settings
2. Try browsing data
3. If it works, you found it!

---

## 💡 Next Steps

1. **Identify your certificate model** using one of the methods above
2. **Update the configuration** in the Flutter app
3. **Test browsing** - the app will show you if the models work
4. **Customize fields** to match your Odoo field names

Need help finding the right model? Let me know what type of data you're trying to print labels for!
