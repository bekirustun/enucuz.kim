import Link from 'next/link';

export default function Navbar() {
  return (
    <nav className="bg-white shadow-md sticky top-0 z-30">
      <div className="max-w-5xl mx-auto flex items-center justify-between px-4 py-3">
        <Link href="/">
          <span className="text-2xl font-bold text-blue-700 tracking-tight">enucuz.kim <span className="text-sm font-light text-gray-400">Admin</span></span>
        </Link>
        <ul className="flex gap-4">
          <li><Link href="/"><span className="hover:text-blue-700">Dashboard</span></Link></li>
          <li><Link href="/products"><span className="hover:text-blue-700">Ürünler</span></Link></li>
          <li><Link href="/stores"><span className="hover:text-blue-700">Mağazalar</span></Link></li>
          <li><Link href="/users"><span className="hover:text-blue-700">Kullanıcılar</span></Link></li>
        </ul>
      </div>
    </nav>
  );
}
