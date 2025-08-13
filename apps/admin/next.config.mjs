/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      { source: "/api/:path*", destination: "http://localhost:3015/api/:path*" },
    ];
  },
};
export default nextConfig;
