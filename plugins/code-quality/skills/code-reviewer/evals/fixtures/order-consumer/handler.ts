import type express from "express";
import { chargeCard } from "./payments";
import { sendEmail } from "./mailer";
import { db } from "./db";

// Pub/Sub push subscription delivers here: POST /events/order-paid
// Subscription has default retry (at-least-once) and a 10s ack deadline.
export async function orderPaidHandler(req: express.Request, res: express.Response) {
  const envelope = req.body;
  const msg = JSON.parse(Buffer.from(envelope.message.data, "base64").toString());
  const { orderId, amountCents, customerEmail } = msg;

  const order = await db.orders.findById(orderId);

  // Charge the customer, then email them, then record the outcome.
  await chargeCard(order.cardToken, amountCents);
  await sendEmail(customerEmail, `Order ${orderId} confirmed`);
  await db.orders.update(orderId, { status: "PAID" });

  res.status(200).send("ok");
}
