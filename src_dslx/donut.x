const NUM_REPORTS = u32:1;
const MAX_CYCLES = u32:16;
const NUM_STATES = u32:8;
type report_t = bits[NUM_REPORTS];
type alphabet_t = bits[256];
type connect_t = bits[NUM_STATES];

fn donut_regex (stream: u8[MAX_CYCLES]) -> report_t[MAX_CYCLES] {
  let active_curr = u1[NUM_STATES]:[u1:1, u1:0, ...];

  // Build alphabets
  let accept = alphabet_t[NUM_STATES]:[
    (alphabet_t:1 << u8:'D') | (alphabet_t:1 << u8:'d'), // state0
    (alphabet_t:1 << u8:'o'), // state1
    (alphabet_t:1 << u8:'n'), // state2
    (alphabet_t:1 << u8:'u'), // state3
    (alphabet_t:1 << u8:'t'), // state4
    (alphabet_t:1 << u8:'u'), // state5
    (alphabet_t:1 << u8:'g'), // state6
    (alphabet_t:1 << u8:'h'), // state7
  ];

  // Build connection matrix
  let connections = connect_t[NUM_STATES]: [
    0b00000010, // state0
    0b00100100, // state1
    0b00001000, // state2
    0b00010000, // state3
    0b00000000, // state4
    0b01000000, // state5
    0b10000000, // state6
    0b00000100, // state7
  ];

  // Build report-enable vector
  // In "donut", only state 4 reports.
  let reports = u1[NUM_STATES]: [
    u1:0, u1:0, u1:0, u1:0,
    u1:1, u1:0, u1:0, u1:0
  ];

  // Primary expression match logic.
  let (active_curr, result) =
  for (i, (active_curr, result)):
    (u32, (u1[NUM_STATES], report_t[MAX_CYCLES])) in
      range(u32:0, MAX_CYCLES) {
      let ch = stream[i];
      let _ = trace!(i);
      let _ = trace!(ch);
      let _ = trace!(active_curr);

      let (result_i, active_next) =
      // For all states, check if the stream char is valid, and update
      // active queue if true.
      for (state_i, (result_i, active_next)): (u32, (report_t, u1[NUM_STATES]))
        in range(u32:0, NUM_STATES) {
          let accept_i = accept[state_i];
          // Check whether this state accept the current character
          let accept_ch = (rev(accept_i) as u1[256])[ch];
          // Activate all neighbors if this state is active 
          let active_next =
          for (neigh, active_next): (u32, u1[NUM_STATES]) in range(u32:0, NUM_STATES) {
            let connect_valid = (connections[state_i] as u1[NUM_STATES])[neigh];
            let next_state_en = connect_valid & accept_ch & active_curr[neigh];
            update(active_next, neigh, next_state_en)
          } (active_next);
          (bit_slice_update(result_i, state_i, reports[state_i] & accept_ch), active_next)
      } ((report_t:0, u1[NUM_STATES]:[u1:0, ...])); 
      let _ = trace!(active_next);

      // Update next cycle's state
      let active_curr =
      for (state_i, active_curr): (u32, u1[NUM_STATES])
        in range(u32:0, NUM_STATES) {
        update(active_curr, state_i, active_next[state_i])
      } (active_curr);

      let result = update(result, i, result_i);
      let _ = trace!(result_i);
      (active_curr, result)
  } ((active_curr, report_t[MAX_CYCLES]:[report_t:0, ...]));

  result
}

#![test]
fn donut_test() {
  let result = donut_regex(u8[MAX_CYCLES]:['d', 'o', 'n', 'u',  't', 0, ...]);
  let _ = assert_eq(result, report_t[MAX_CYCLES]:[
    0, 0, 0, 0, 1, 0, ...]);
  ()
}
