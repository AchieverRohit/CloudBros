import pool from '../../../../db';

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const tag = searchParams.get('tag');
    const code = searchParams.get('code') || 'USD';

    if (!tag) {
      return new Response(JSON.stringify({ error: 'Tag is required' }), { status: 400 });
    }

    // Fetch hosting plan & features
    const [planRows] = await pool.query(`
      SELECT 
        hp.hostingplanid, hp.name AS plan_name, hp.tag, hp.description,
        f.name AS feature_name, f.featuretype, hpf.value AS feature_value, hpf.isavailable
      FROM hostingplans hp
      LEFT JOIN hostingplanfeatures hpf ON hp.hostingplanid = hpf.hostingplanid
      LEFT JOIN features f ON hpf.featureid = f.featureid
      WHERE hp.tag = ? AND hp.isactive = 1
    `, [tag]);

    if (planRows.length === 0) {
      return new Response(JSON.stringify({ message: 'No data found' }), { status: 404 });
    }

    const hostingplanid = planRows[0].hostingplanid;

    // Fetch pricing
    const [pricingRows] = await pool.query(`
      SELECT b.hostingbillingcycleid, b.name AS billing_cycle, p.price
      FROM hostingpricing p
      JOIN hostingbillingcycles b ON p.hostingbillingcycleid = b.hostingbillingcycleid
      WHERE p.hostingplanid = ?
    `, [hostingplanid]);

    // Fetch currency
    const [[currencyRow]] = await pool.query(`
      SELECT code, conversionrate, symbol FROM currencies WHERE code = ?
    `, [code]);

    if (!currencyRow) {
      return new Response(JSON.stringify({ error: 'Invalid currency code' }), { status: 400 });
    }

    // Fetch discounts
    const [discountRows] = await pool.query(`
      SELECT hostingbillingcycleid, discount_type, discount_value
      FROM hostingplandiscounts
      WHERE hostingplanid = ? AND isactive = 1
    `, [hostingplanid]);

    const plan = {
      hostingplanid,
      name: planRows[0].plan_name,
      tag: planRows[0].tag,
      description: planRows[0].description,
      features: [],
      pricing: []
    };

    // Features
    planRows.forEach(row => {
      if (row.feature_name) {
        plan.features.push({
          name: row.feature_name,
          type: row.featuretype,
          value: row.feature_value,
          isavailable: row.isavailable
        });
      }
    });

    // Pricing
    pricingRows.forEach(row => {
  const convertedPrice = row.price * currencyRow.conversionrate; // Keep as number

  // Find matching discount for this billing cycle
  const discount = discountRows.find(d => d.hostingbillingcycleid === row.hostingbillingcycleid);

  let finalPrice = convertedPrice;
  let appliedDiscount = 0;

  if (discount) {
    if (discount.discount_type === 'fixed') {
      appliedDiscount = discount.discount_value;
      finalPrice = convertedPrice - appliedDiscount;
    } else if (discount.discount_type === 'percentage') {
      appliedDiscount = (convertedPrice * discount.discount_value) / 100;
      finalPrice = convertedPrice - appliedDiscount;
    }
    if (finalPrice < 0) finalPrice = 0; // Prevent negative price
  }

  plan.pricing.push({
    cycle: row.billing_cycle,
    original_price: convertedPrice.toFixed(2),
    discount_type: discount ? discount.discount_type : null,
    discount_value: discount ? discount.discount_value : 0,
    applied_discount: discount ? appliedDiscount.toFixed(2) : 0,
    final_price: finalPrice.toFixed(2),
    currency: currencyRow.code,
    symbol: currencyRow.symbol
  });
});


    return new Response(JSON.stringify(plan), { status: 200 });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}
