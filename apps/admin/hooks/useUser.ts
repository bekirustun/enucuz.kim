import { useState, useEffect } from 'react';

export function useUser() {
  const [user, setUser] = useState<{ name: string; role: string } | null>(null);

  useEffect(() => {
    // API entegrasyonuyla değişecek (dummy örnek)
    setUser({ name: "Bekir Ustun", role: "Admin" });
  }, []);

  return user;
}
