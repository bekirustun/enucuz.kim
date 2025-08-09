// apps/web/components/product-cards/ProductCard.tsx

import { Product } from '../../types/product'
import { formatPrice } from '../../utils/formatPrice'

export default function ProductCard({ product }: { product: Product }) {
  return (
    <div className="border rounded-xl p-4 shadow bg-white flex flex-col items-center">
      <img src={product.image} alt={product.name} className="w-32 h-32 object-contain mb-2" />
      <div className="font-semibold text-lg mb-1">{product.name}</div>
      <div className="text-blue-700 font-bold mb-2">{formatPrice(product.price)}</div>
      <div className="text-xs text-gray-500 mb-2">{product.shop}</div>
      {product.affiliateLink && (
        <a
          href={product.affiliateLink}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-2 px-3 py-1 bg-blue-600 text-white rounded-full text-xs hover:bg-blue-800"
        >
          Satın Al
        </a>
      )}
    </div>
  )
}
