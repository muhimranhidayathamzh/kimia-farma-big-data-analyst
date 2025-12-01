-- Membuat tabel analisa final Kimia Farma
CREATE OR REPLACE TABLE `rakamin-kimia-farma-479911.kimia_farma.kf_analisa_final` AS

-- CTE transaksi
WITH trx AS (
  SELECT
    transaction_id,
    date,
    branch_id,
    customer_name,
    product_id,
    price,
    discount_percentage,
    rating AS rating_transaksi
  FROM `rakamin-kimia-farma-479911.kimia_farma.kf_final_transaction`
),

-- CTE product
product AS (
  SELECT
    product_id,
    product_name
  FROM `rakamin-kimia-farma-479911.kimia_farma.kf_product`
),

-- CTE kantor cabang
cabang AS (
  SELECT
    branch_id,
    branch_name,
    kota,
    provinsi,
    rating AS rating_cabang
  FROM `rakamin-kimia-farma-479911.kimia_farma.kf_kantor_cabang`
)

-- Tabel analisa final
SELECT
  t.transaction_id,
  t.date,
  t.branch_id,
  c.branch_name,
  c.kota,
  c.provinsi,
  c.rating_cabang,
  t.customer_name,
  t.product_id,
  p.product_name,
  t.price AS actual_price,
  t.discount_percentage,

  -- persentase gross laba sesuai ketentuan
  CASE 
    WHEN t.price <= 50000 THEN 0.10
    WHEN t.price <= 100000 THEN 0.15
    WHEN t.price <= 300000 THEN 0.20
    WHEN t.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS persentase_gross_laba,

  -- harga setelah diskon
  t.price * (1 - t.discount_percentage/100) AS nett_sales,

  -- keuntungan = nett_sales * persentase laba
  (t.price * (1 - t.discount_percentage/100)) *
  CASE 
    WHEN t.price <= 50000 THEN 0.10
    WHEN t.price <= 100000 THEN 0.15
    WHEN t.price <= 300000 THEN 0.20
    WHEN t.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS nett_profit,

  t.rating_transaksi

FROM trx t
LEFT JOIN product p ON t.product_id = p.product_id
LEFT JOIN cabang c ON t.branch_id = c.branch_id;
