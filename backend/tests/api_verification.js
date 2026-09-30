process.env.NODE_ENV = "test";

import http from "http";
import crypto from "crypto";
import app from "../index.js";

async function runTests() {
  console.log("=========================================");
  console.log("Starting Backend Automated API Verification");
  console.log("=========================================\n");

  const server = http.createServer(app);
  // Listen on port 0 for dynamic ephemeral port allocation
  await new Promise((resolve) => server.listen(0, resolve));
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}`;

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
    assert(delivery1001.version === 1, "Initial version is 1");

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
    assert(notFoundData.code === "DELIVERY_NOT_FOUND", "Error code is DELIVERY_NOT_FOUND");

    // 5. POST /deliveries/1001/complete (Validation Error - Missing recipient_name)
    console.log("\nTest 5: POST /deliveries/1001/complete - Missing recipient_name (400 expected)");
    const invalidCompleteRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ client_action_id: crypto.randomUUID() })
    });
    const invalidCompleteData = await invalidCompleteRes.json();
    assert(invalidCompleteRes.status === 400, "Status is 400");
    assert(invalidCompleteData.code === "VALIDATION_ERROR", "Error code is VALIDATION_ERROR");

    // 6. Validation Error - Whitespace recipient_name
    console.log("\nTest 6: POST /deliveries/1001/complete - Whitespace-only name (400 expected)");
    const whitespaceRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "    ",
        client_action_id: crypto.randomUUID()
      })
    });
    assert(whitespaceRes.status === 400, "Whitespace recipient rejected with 400");

    // 7. POST /deliveries/1001/complete (Success)
    console.log("\nTest 7: POST /deliveries/1001/complete - Success");
    const actionId1001 = crypto.randomUUID();
    const completeRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "Ahmed Ali",
        note: "Delivered to apartment door",
        client_action_id: actionId1001
      })
    });
    const completeData = await completeRes.json();
    assert(completeRes.status === 200, "Status is 200");
    assert(completeData.delivery.status === "delivered", "Status updated to delivered");
    assert(completeData.delivery.version === 2, "Version incremented to 2");

    // 8. Duplicate Submission / Idempotency Replay
    console.log("\nTest 8: POST /deliveries/1001/complete - Duplicate submission replay");
    const duplicateRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "Ahmed Ali",
        note: "Delivered to apartment door",
        client_action_id: actionId1001
      })
    });
    const duplicateData = await duplicateRes.json();
    assert(duplicateRes.status === 200, "Duplicate request returns 200 OK");
    assert(duplicateRes.headers.get("x-idempotent-replay") === "true", "Header X-Idempotent-Replay is true");
    assert(duplicateData.delivery.id === 1001, "Returned delivery id is 1001");

    // 9. Cross-delivery idempotency reuse prevention
    console.log("\nTest 9: Attempt reusing actionId1001 on delivery 1002 (409 expected)");
    const crossReuseRes = await fetch(`${baseUrl}/deliveries/1002/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "Different Person",
        client_action_id: actionId1001
      })
    });
    const crossReuseData = await crossReuseRes.json();
    assert(crossReuseRes.status === 409, "Cross-delivery ID reuse rejected with 409 Conflict");
    assert(crossReuseData.code === "IDEMPOTENCY_KEY_REUSE", "Error code is IDEMPOTENCY_KEY_REUSE");

    // 10. Conflict Detection - Attempt modifying already completed delivery 1001 with new action ID
    console.log("\nTest 10: Attempt modifying already completed delivery (409 expected)");
    const conflictRes = await fetch(`${baseUrl}/deliveries/1001/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        recipient_name: "Another Person",
        client_action_id: crypto.randomUUID()
      })
    });
    const conflictData = await conflictRes.json();
    assert(conflictRes.status === 409, "Modification on delivered order returns 409 Conflict");
    assert(conflictData.code === "DELIVERY_CONFLICT", "Error code is DELIVERY_CONFLICT");

    // 11. POST /deliveries/1002/fail (Success)
    console.log("\nTest 11: POST /deliveries/1002/fail - Mark as failed");
    const failActionId = crypto.randomUUID();
    const failRes = await fetch(`${baseUrl}/deliveries/1002/fail`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        reason: "customer_unavailable",
        note: "Called customer 3 times, phone switched off",
        client_action_id: failActionId
      })
    });
    const failData = await failRes.json();
    assert(failRes.status === 200, "Status is 200");
    assert(failData.delivery.status === "failed", "Status updated to failed");
    assert(failData.delivery.failure_reason === "customer_unavailable", "Failure reason recorded");

    // 12. POST /deliveries/1001/proof (Upload Photo Proof)
    console.log("\nTest 12: POST /deliveries/1001/proof - Multipart photo upload");
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
    const photoRes = await fetch(`${baseUrl}${uploadData.proof_url}`);
    assert(photoRes.status === 200, "Uploaded photo can be retrieved");
    assert(Buffer.from(await photoRes.arrayBuffer()).equals(dummyImageBytes), "Retrieved photo matches the upload");

  } finally {
    server.close(() => {
      process.exit(failed > 0 ? 1 : 0);
    });
  }

  console.log("\n=========================================");
  console.log(`Results: ${passed} passed, ${failed} failed`);
  console.log("=========================================");
}

runTests().catch((err) => {
  console.error("Test execution failed:", err);
  process.exit(1);
});
