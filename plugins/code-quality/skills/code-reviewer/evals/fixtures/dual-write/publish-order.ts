import { db } from "./db";
import { pubsub } from "./pubsub";

// Called when an order ships. Persist the new state, then notify downstream
// services (billing, notifications, analytics) via a topic.
export async function markShipped(orderId: string, trackingCode: string) {
  await db.orders.update(orderId, { status: "SHIPPED", trackingCode });
  await pubsub.topic("order-shipped").publishJSON({ orderId, trackingCode });
  return { ok: true };
}
