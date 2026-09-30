import assert from "node:assert/strict";
import { test } from "node:test";
import { deliveriesDB } from "../config/database.js";
import { testDeliverySeed } from "../config/test_delivery_seed.js";

test("forty unique test orders include thirty new pending deliveries", () => {
  assert.equal(deliveriesDB.length, 40);
  assert.equal(new Set(deliveriesDB.map((delivery) => delivery.id)).size, 40);
  assert.equal(new Set(deliveriesDB.map((delivery) => delivery.order_number)).size, 40);
  assert.equal(testDeliverySeed.length, 30);
  assert.ok(testDeliverySeed.every((delivery) => delivery.status === "pending" && delivery.version === 1));
  assert.equal(testDeliverySeed[0].id, 1011);
  assert.equal(testDeliverySeed.at(-1).id, 1040);
});
