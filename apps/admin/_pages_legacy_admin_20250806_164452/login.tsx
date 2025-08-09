import { useState } from 'react';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    // API ile login olacak (şimdilik dummy)
    alert("Giriş başarılı! (Demo)");
  }

  return (
    <main className="min-h-screen flex items-center justify-center bg-gray-100">
      <form className="bg-white shadow rounded-2xl p-8 w-full max-w-sm" onSubmit={handleLogin}>
        <h1 className="text-2xl font-bold text-blue-700 mb-4">Admin Giriş</h1>
        <input
          type="email"
          placeholder="E-posta"
          className="mb-3 w-full border rounded px-3 py-2"
          value={email}
          onChange={e => setEmail(e.target.value)}
          required
        />
        <input
          type="password"
          placeholder="Şifre"
          className="mb-4 w-full border rounded px-3 py-2"
          value={password}
          onChange={e => setPassword(e.target.value)}
          required
        />
        <button type="submit" className="w-full bg-blue-700 text-white py-2 rounded hover:bg-blue-800 transition">Giriş Yap</button>
      </form>
    </main>
  );
}
