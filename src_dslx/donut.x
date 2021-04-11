const NUM_REPORTS = u32:1;
const MAX_CYCLES = u32:256;
const NUM_STATES = u32:8;
type report_t = bits[NUM_REPORTS];

fn donut_regex (stream: u8[MAX_CYCLES]) -> report_t[MAX_CYCLES] {
  let active_curr: u1[NUM_STATES] = u1[NUM_STATES]:[u1:1, u1:0, ...];
  let active_next: u1[NUM_STATES] = u1[NUM_STATES]:[u1:0, ...]; 
  let result = report_t[256]:[report_t:0, ...];
  result
}

#![test]
fn donut_test (){
  assert_eq(donut_regex(u8[MAX_CYCLES]:[u8:123, 0, ...]),
            report_t[MAX_CYCLES]:[report_t:0, ...])
}
