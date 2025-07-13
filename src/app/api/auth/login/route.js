import pool from '../../../../db';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;

export async function POST(request) {
  const { email, password } = await request.json();

  try {
    const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    const user = users[0];

    if (!user) {
      return new Response(JSON.stringify({ error: 'Invalid credentials' }), { status: 400 });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return new Response(JSON.stringify({ error: 'Invalid credentials' }), { status: 400 });
    }
    console.log(JWT_SECRET);
    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '1d' });

    return new Response(JSON.stringify({ message: 'Login successful', token }), { status: 200 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
  }
}
