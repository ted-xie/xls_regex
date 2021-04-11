const NUM_REPORTS = u32:1;
const MAX_CYCLES = u32:256;
const NUM_STATES = u32:8;
type report_t = bits[NUM_REPORTS];
type alphabet_t = bits[256];

fn donut_regex (stream: u8[MAX_CYCLES]) -> report_t[MAX_CYCLES] {
  let active_curr = u1[NUM_STATES]:[u1:1, u1:0, ...];
  let active_next = u1[NUM_STATES]:[u1:0, ...]; 
  let result = report_t[256]:[report_t:0, ...];

  // Build alphabets
  let accept = alphabet_t[NUM_STATES]:[
    (alphabet_t:1 << u8:'D') | (alphabet_t:1 << u8:'d'),
    (alphabet_t:1 << u8:'o'),
    (alphabet_t:1 << u8:'n'),
    (alphabet_t:1 << u8:'u'),
    (alphabet_t:1 << u8:'t'),
    (alphabet_t:1 << u8:'u'),
    (alphabet_t:1 << u8:'g'),
    (alphabet_t:1 << u8:'h'),
  ];
  result
}

#![test]
fn donut_test() {
  assert_eq(donut_regex(u8[MAX_CYCLES]:[u8:123, 0, ...]),
            report_t[MAX_CYCLES]:[report_t:0, ...])
}
