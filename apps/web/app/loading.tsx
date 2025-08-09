export default function Loading() {
  return (
    <main className='flex flex-col items-center justify-center min-h-screen'>
      <span className='animate-spin text-4xl'>⏳</span>
      <p className='mt-2 text-gray-500'>Yükleniyor...</p>
    </main>
  );
}
