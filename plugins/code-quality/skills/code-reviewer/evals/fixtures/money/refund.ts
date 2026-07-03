// Amounts are in whole currency units (e.g. dollars). pct is 0..100.

export function orderTotal(items: { price: number; qty: number }[]): number {
  return items.reduce((sum, i) => sum + i.price * i.qty, 0);
}

export function computeRefund(order: { total: number }, pct: number): number {
  const refund = order.total * (pct / 100);
  return Math.round(refund * 100) / 100; // round to cents
}
