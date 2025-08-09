import Navbar from '../../components/Navbar';

export default function ProductList() {
  // Dummy veri, ileride API ile dinamik olacak
  const products = [
    { id: 1, name: "iPhone 15", price: 49999, store: "Hepsiburada" },
    { id: 2, name: "Samsung S24", price: 41999, store: "Trendyol" },
  ];

  return (
    <>
      <Navbar />
      <main className="max-w-4xl mx-auto py-8 px-4">
        <h1 className="text-2xl font-bold mb-6">Ürünler</h1>
        <table className="w-full bg-white rounded-2xl shadow">
          <thead>
            <tr className="text-left text-gray-600">
              <th className="p-3">#</th>
              <th className="p-3">Ürün Adı</th>
              <th className="p-3">Fiyat</th>
              <th className="p-3">Mağaza</th>
            </tr>
          </thead>
          <tbody>
            {products.map((p) => (
              <tr key={p.id} className="border-t last:border-b">
                <td className="p-3">{p.id}</td>
                <td className="p-3">{p.name}</td>
                <td className="p-3">{p.price.toLocaleString()} TL</td>
                <td className="p-3">{p.store}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </main>
    </>
  );
}
