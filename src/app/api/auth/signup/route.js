import pool from '../../../../db';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;

export async function POST(request) {
  const { email, password,firstname,lastname,phone } = await request.json();

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const [existing] = await pool.query('SELECT userid FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return new Response(JSON.stringify({ error: 'User already exists' }), { status: 400 });
    }

    const [result] = await pool.query('INSERT INTO users (email, password,firstname,lastname,phone) VALUES (?, ?,?,?,?)', [email, hashedPassword,firstname,lastname,phone]);
    
    const userId = result.insertId;
    const token = jwt.sign({ id: userId }, JWT_SECRET, { expiresIn: '1d' });
  
    return new Response(JSON.stringify({ message: 'Signup successful',token }), { status: 201 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Something went wrong' }), { status: 500 });
  }
}