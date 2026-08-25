// Reads the ABAP Unit results produced by the abaplint transpiler and turns
// them into readable console output plus a non-zero exit code on failure,
// so that GitHub Actions marks the run as failed.
//
// A run that reports no tests at all is also a failure: if the transpiler ever
// stops emitting the test include, "0 of 0 passed" would otherwise be green
// and the build would silently stop checking anything.
import fs from "fs";

const RESULT_FILE = "output/output.json";

if (fs.existsSync(RESULT_FILE) === false) {
  console.error(`No result file found at ${RESULT_FILE}`);
  process.exit(1);
}

const results = JSON.parse(fs.readFileSync(RESULT_FILE, "utf8"));

if (Array.isArray(results) === false) {
  console.error(`Expected an array of results in ${RESULT_FILE}`);
  process.exit(1);
}

if (results.length === 0) {
  console.error(`No tests reported in ${RESULT_FILE} - refusing to pass an empty run`);
  process.exit(1);
}

const failed = results.filter((test) => test.status !== "SUCCESS");

for (const test of results) {
  const icon = test.status === "SUCCESS" ? "PASS" : "FAIL";
  console.log(`${icon}  ${test.testclass_name} -> ${test.method_name}`);
  if (test.status !== "SUCCESS") {
    console.log(`      expected: ${test.expected}`);
    console.log(`      actual:   ${test.actual}`);
    console.log(`      message:  ${test.message}`);
  }
}

console.log("");
console.log(`${results.length - failed.length}/${results.length} tests passed`);

process.exit(failed.length === 0 ? 0 : 1);
