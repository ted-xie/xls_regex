const NUM_REPORTS = u32:1;
const MAX_CYCLES = u32:256;
const NUM_STATES = u32:8;
type report_t = bits[NUM_REPORTS];
type alphabet_t = bits[256];

fn donut_regex (stream: u8[MAX_CYCLES]) -> report_t[MAX_CYCLES] {
  let active_curr = u1[NUM_STATES]:[u1:1, u1:0, ...];
  let active_next = u1[NUM_STATES]:[u1:0, ...]; 
  let result = report_t[256]:[report_t:0, ...];

  // Build individual alphabets
  // Update state0 alphabet
  let accept0 = alphabet_t:0 | (alphabet_t:1 << u8:'D') |
    (alphabet_t:1 << u8:'d');
  let _ = trace!(accept0);
  // Update state1 alphabet
  let accept1 = alphabet_t:0 | (alphabet_t:1 << u8:'o');
  let _ = trace!(accept1);
  // Update state2 alphabet
  let accept2 = alphabet_t:0 | (alphabet_t:1 << u8:'n');
  let _ = trace!(accept2);
  // Update state3 alphabet
  let accept3 = alphabet_t:0 | (alphabet_t:1 << u8:'u');
  let _ = trace!(accept3);
  // Update state4 alphabet
  let accept4 = alphabet_t:0 | (alphabet_t:1 << u8:'t');
  let _ = trace!(accept4);
  // Update state5 alphabet
  let accept5 = alphabet_t:0 | (alphabet_t:1 << u8:'n');
  let _ = trace!(accept5);
  // Update state6 alphabet
  let accept6 = alphabet_t:0 | (alphabet_t:1 << u8:'u');
  let _ = trace!(accept6);
  // Update state7 alphabet
  let accept7 = alphabet_t:0 | (alphabet_t:1 << u8:'t');
  let _ = trace!(accept7);

  // TODO(tedx): This should be written as some kind of inline expression.
  let accept = alphabet_t[NUM_STATES]:[
    accept0, accept1, accept2, accept3,
    accept4, accept5, accept6, accept7
  ];
  result
}

#![test]
fn donut_test() {
  assert_eq(donut_regex(u8[MAX_CYCLES]:[u8:123, 0, ...]),
            report_t[MAX_CYCLES]:[report_t:0, ...])
}
