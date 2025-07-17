import pool from '../../../../db';

export async function GET() {
  try {
    const [features] = await pool.query('SELECT * FROM features');
    return new Response(JSON.stringify(features), { status: 200 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { name, featuretype } = await request.json();

    const [result] = await pool.query(`
      INSERT INTO features (name, featuretype) 
      VALUES (?, ?)
    `, [name, featuretype]);

    return new Response(JSON.stringify({ message: 'Feature added', id: result.insertId }), { status: 201 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}
