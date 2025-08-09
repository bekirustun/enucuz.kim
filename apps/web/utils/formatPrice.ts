// apps/web/utils/formatPrice.ts

export function formatPrice(amount: number) {
  return amount.toLocaleString('tr-TR', {
    style: 'currency',
    currency: 'TRY'
  });
}
