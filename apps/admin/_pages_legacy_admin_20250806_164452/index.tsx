import Navbar from '../components/Navbar';

export default function AdminDashboard() {
  return (
    <>
      <Navbar />
      <main className="min-h-screen bg-gray-50 py-8 px-6">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold mb-2 text-blue-700">Enucuz.kim Admin Paneline Hoşgeldiniz</h1>
          <p className="text-lg text-gray-600 mb-8">Burası, Türkiye’nin en gelişmiş karşılaştırma platformunun yönetim merkezidir.</p>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-white rounded-2xl shadow p-6">
              <h2 className="text-xl font-semibold mb-2">Ürünler</h2>
              <p className="text-gray-500">Ürün ekleyin, güncelleyin veya silin.</p>
            </div>
            <div className="bg-white rounded-2xl shadow p-6">
              <h2 className="text-xl font-semibold mb-2">Mağazalar</h2>
              <p className="text-gray-500">Affiliate mağaza bilgilerini yönetin.</p>
            </div>
            <div className="bg-white rounded-2xl shadow p-6">
              <h2 className="text-xl font-semibold mb-2">Kullanıcılar</h2>
              <p className="text-gray-500">Yönetici ve yetkilileri kontrol edin.</p>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}

