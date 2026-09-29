process.env.NODE_ENV = "test";

import http from "http";
import app from "../index.js";

const PORT = 3099;

async function runTests() {
  console.log("=========================================");
  console.log("Starting Backend Automated API Verification");
  console.log("=========================================\n");

  const server = http.createServer(app);
  await new Promise((resolve) => server.listen(PORT, resolve));
  const baseUrl = `http://localhost:${PORT}`;

  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${message}`);
      failed++;
    }
  }

  try {
    // 1. Health check
    console.log("Test 1: Health check GET /");
    const healthRes = await fetch(`${baseUrl}/`);
    const healthData = await healthRes.json();
    assert(healthRes.status === 200, "Status is 200");
    assert(healthData.status === "online", "Response reports status online");

    // 2. GET /deliveries
    console.log("\nTest 2: GET /deliveries");
    const listRes = await fetch(`${baseUrl}/deliveries`);
    const listData = await listRes.json();
    assert(listRes.status === 200, "Status is 200");
    assert(Array.isArray(listData) && listData.length >= 4, "Returns array of at least 4 deliveries");
    const delivery1001 = listData.find((d) => d.id === 1001);
    assert(delivery1001 !== undefined, "Contains delivery 1001");
    assert(delivery1001.order_number === "ORD-1001", "Order number is ORD-1001");
    assert(delivery1001.status === "pending", "Initial status is pending");

    // 3. GET /deliveries/1001
    console.log("\nTest 3: GET /deliveries/1001");
    const singleRes = await fetch(`${baseUrl}/deliveries/1001`);
    const singleData = await singleRes.json();
    assert(singleRes.status === 200, "Status is 200");
    assert(singleData.id === 1001, "Fetched delivery id is 1001");
    assert(singleData.customer_name === "Ahmed Ali", "Customer name matches");

    // 4. GET /deliveries/99999 (Not Found)
    console.log("\nTest 4: GET /deliveries/99999 (404 expected)");
    const notFoundRes = await fetch(`${baseUrl}/deliveries/99999`);
    const notFoundData = await notFoundRes.json();
    assert(notFoundRes.status === 404, "Status is 404");
    assert(notFoundData.message === "Delivery not found", "Returns proper 404 message");

    // 5. POST /deliveries/1001/complete (Validation Error)
    console.log("\nTest 5: POST /deliveries/1001/complete - Missing recipient_name (400 expected)");
    const invalidCompleteRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ client_action_id: "uuid-test-1" })
    });
    const invalidCompleteData = await invalidCompleteRes.json();
    assert(invalidCompleteRes.status === 400, "Status is 400");
    assert(invalidCompleteData.message.includes("recipient_name is required"), "Validation error mentions recipient_name");

    // 6. POST /deliveries/1001/complete (Success)
    console.log("\nTest 6: POST /deliveries/1001/complete - Success");
    const completeRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "Ahmed Ali",
        note: "Delivered to apartment door",
        client_action_id: "action-complete-1001"
      })
    });
    const completeData = await completeRes.json();
    assert(completeRes.status === 200, "Status is 200");
    assert(completeData.delivery.status === "delivered", "Status updated to delivered");
    assert(completeData.delivery.recipient_name === "Ahmed Ali", "Recipient name recorded");

    // 7. Duplicate Submission / Idempotency Replay
    console.log("\nTest 7: POST /deliveries/1001/complete - Duplicate submission replay");
    const duplicateRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "Ahmed Ali",
        note: "Delivered to apartment door",
        client_action_id: "action-complete-1001"
      })
    });
    const duplicateData = await duplicateRes.json();
    assert(duplicateRes.status === 200, "Duplicate request returns 200 OK");
    assert(duplicateRes.headers.get("x-idempotent-replay") === "true", "Header X-Idempotent-Replay is true");
    assert(duplicateData.delivery.status === "delivered", "Returns original delivered payload without error");

    // 8. POST /deliveries/1002/fail (Success)
    console.log("\nTest 8: POST /deliveries/1002/fail - Mark as failed");
    const failRes = await fetch(`${baseUrl}/deliveries/1002/fail`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        reason: "customer_unavailable",
        note: "Called customer 3 times, phone switched off",
        client_action_id: "action-fail-1002"
      })
    });
    const failData = await failRes.json();
    assert(failRes.status === 200, "Status is 200");
    assert(failData.delivery.status === "failed", "Status updated to failed");
    assert(failData.delivery.failure_reason === "customer_unavailable", "Failure reason recorded");

    // 9. POST /deliveries/1001/proof (Upload Photo Proof)
    console.log("\nTest 9: POST /deliveries/1001/proof - Multipart photo upload");
    const boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW";
    const dummyImageBytes = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46]);
    const multipartBody = Buffer.concat([
      Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="photo"; filename="proof.jpg"\r\nContent-Type: image/jpeg\r\n\r\n`),
      dummyImageBytes,
      Buffer.from(`\r\n--${boundary}--\r\n`)
    ]);

    const uploadRes = await fetch(`${baseUrl}/deliveries/1001/proof`, {
      method: "POST",
      headers: {
        "Content-Type": `multipart/form-data; boundary=${boundary}`
      },
      body: multipartBody
    });
    const uploadData = await uploadRes.json();
    assert(uploadRes.status === 200, "Status is 200");
    assert(uploadData.proof_url !== undefined && uploadData.proof_url.startsWith("/uploads/"), "Photo uploaded and proof_url generated");

  } finally {
    server.close();
  }

  console.log("\n=========================================");
  console.log(`Results: ${passed} passed, ${failed} failed`);
  console.log("=========================================");

  if (failed > 0) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error("Test execution failed:", err);
  process.exit(1);
});
