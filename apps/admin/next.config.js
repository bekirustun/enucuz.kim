/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  webpack: (config) => {
    if (process.env.NODE_ENV === "development") {
      config.cache = { type: "memory" }; // Windows dosya kilidi sorunlarını azaltır
    }
    return config;
  },
};
module.exports = nextConfig;
