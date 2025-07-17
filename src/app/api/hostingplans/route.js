import pool from '../../../db';

export async function GET() {
  try {
    const [plans] = await pool.query(`
      SELECT * FROM hostingplans
    `);
    return new Response(JSON.stringify(plans), { status: 200 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { name, tag, description, isactive } = await request.json();

    const [result] = await pool.query(`
      INSERT INTO hostingplans (name, tag, description, isactive) 
      VALUES (?, ?, ?, ?)
    `, [name, tag, description, isactive]);

    return new Response(JSON.stringify({ message: 'Hosting plan created', id: result.insertId }), { status: 201 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}
