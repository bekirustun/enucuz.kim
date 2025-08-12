export const features = {
  admin: {
    dashboard: { enabled: true },
    settings: {
      enabled: true,
      theme: { enabled: true },
      users: { enabled: true },
    },
    products: {
      enabled: false, // gerekirse aç
      variants: { enabled: false },
      bulkImport: { enabled: false },
    },
  },
} as const;
