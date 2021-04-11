const NUM_REPORTS = u32:1;
const MAX_CYCLES = u32:256;
const NUM_STATES = u32:8;
type report_t = bits[NUM_REPORTS];
type alphabet_t = bits[256];
type connect_t = bits[NUM_STATES];

fn donut_regex (stream: u8[MAX_CYCLES]) -> report_t[MAX_CYCLES] {
  let active_curr = u1[NUM_STATES]:[u1:1, u1:0, ...];
  let active_next = u1[NUM_STATES]:[u1:0, ...]; 

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
  let _ = trace!(accept);

  // Build connection matrix
  let connections = connect_t[NUM_STATES]: [
    connect_t:0b00000010, // state0
    connect_t:0b00100100, // state1
    connect_t:0b00001000, // state2
    connect_t:0b00010000, // state3
    connect_t:0b00000000, // state4
    connect_t:0b01000000, // state5
    connect_t:0b10000000, // state6
    connect_t:0b00000100, // state7
  ];

  // Build report-enable vector
  // In "donut", only state 4 reports.
  let reports = u1[NUM_STATES]: [
    u1:0, u1:0, u1:0, u1:0,
    u1:1, u1:0, u1:0, u1:0
  ];

  // Primary expression match logic.
  let result =
  for (i, result_): (u32, report_t[MAX_CYCLES]) in
    range(u32:0, MAX_CYCLES) {
    let _ = trace!(i);
    update(result_, u8:0, report_t:0)
    //report_t[MAX_CYCLES]:[report_t:0, ...]
  } (report_t[MAX_CYCLES]:[report_t:0, ...]);

  result
}

#![test]
fn donut_test() {
  let _ = assert_eq(donut_regex(u8[MAX_CYCLES]:[u8:123, 0, ...]),
            report_t[MAX_CYCLES]:[report_t:0, ...]);
  //let _ = assert_eq(donut_regex(u8[MAX_CYCLES]:[
  //          u8:'D', 'o', 'n', 'u', 't', 0, ...]),
  //          report_t[MAX_CYCLES]:[report_t:0, ...]);
  ()
}
