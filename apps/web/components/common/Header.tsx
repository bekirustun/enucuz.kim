import Link from 'next/link'

export default function Header() {
  return (
    <header className="w-full py-4 px-6 bg-white shadow flex items-center justify-between">
      <Link href="/">
        <span className="text-2xl font-bold text-blue-600">enucuz.kim</span>
      </Link>
      <nav>
        <Link href="/about" className="text-gray-700 mr-4">Hakkında</Link>
        <Link href="/contact" className="text-gray-700">İletişim</Link>
      </nav>
    </header>
  )
}
