import pool from '../../../db';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;

export async function POST(request) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
    }

    const token = authHeader.split(' ')[1];
    let decoded;
    try {
      decoded = jwt.verify(token, JWT_SECRET);
    } catch (err) {
      return new Response(JSON.stringify({ error: 'Invalid token' }), { status: 403 });
    }

    const userid = decoded.id;
    const { items, currency = 'USD', paymentmethod = 'unpaid' } = await request.json();

    if (!items || !Array.isArray(items) || items.length === 0) {
      return new Response(JSON.stringify({ error: 'Order items are required' }), { status: 400 });
    }

    // Calculate total price
    let totalPrice = 0;
    for (const item of items) {
      if (!item.item_type || !item.item_id || !item.billing_cycle || !item.price) {
        return new Response(JSON.stringify({ error: 'Invalid order item structure' }), { status: 400 });
      }
      const discount = item.discount || 0;
      const finalPrice = item.price - discount;
      totalPrice += finalPrice;
    }

    // Start transaction
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Insert order
      const [orderResult] = await connection.query(
        `INSERT INTO orders (userid, totalprice, currency, paymentmethod) VALUES (?, ?, ?, ?)`,
        [userid, totalPrice.toFixed(2), currency, paymentmethod]
      );
      const orderid = orderResult.insertId;

      // Insert items
      for (const item of items) {
        const discount = item.discount || 0;
        const finalPrice = item.base_price - discount;
        await connection.query(
          `INSERT INTO orderitems (orderid, item_type, item_id, billing_cycle, price, discount, final_price)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [orderid, item.item_type, item.item_id, item.billing_cycle, item.price, discount, finalPrice.toFixed(2)]
        );
      }

      await connection.commit();
      connection.release();

      return new Response(JSON.stringify({
        message: 'Order created successfully',
        orderid,
        totalprice: totalPrice.toFixed(2),
        currency
      }), { status: 201 });

    } catch (err) {
      await connection.rollback();
      connection.release();
      throw err;
    }

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}
