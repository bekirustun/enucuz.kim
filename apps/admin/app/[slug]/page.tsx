import { notFound } from "next/navigation";

type PageProps = { params: Promise<{ slug?: string }> };

export default async function AdminPage({ params }: PageProps) {
  const { slug } = await params;
  if (!slug) return notFound();

  return (
    <main className="p-8">
      <h1 className="text-2xl">Dinamik Sayfa: {slug}</h1>
    </main>
  );
}
