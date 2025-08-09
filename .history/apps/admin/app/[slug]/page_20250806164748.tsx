import { notFound } from 'next/navigation';

type PageProps = { params: { slug: string } };

export default function AdminPage({ params }: PageProps) {
  const { slug } = params;
  if (!slug) return notFound();
  return (
    <main className='p-8'>
      <h1 className='text-2xl font-bold mb-2'>Admin Route: {slug}</h1>
      <p className='text-gray-600'>Burada {slug} yönetim detayı olacak.</p>
    </main>
  );
}
