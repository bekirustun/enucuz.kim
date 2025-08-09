/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ["cdn.example.com"], // Gerektiğinde CDN domainlerini ekle
  },
};

module.exports = nextConfig;
