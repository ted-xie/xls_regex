#ifndef __SYNTHESIS__
#include <iostream>
#endif

#define kNumStates (8)
#define N (256)

#pragma hls_top
void donut(const char stream[256], bool result[256][1], const int N_unused) {
  // Recognizes the regular expression /[Dd]o(ugh)?nut/
  //const int kNumStates = 8;
  bool active_curr[kNumStates] = {true, false, false, false,
                      false, false, false, false};
  bool accept[kNumStates][256];
#pragma hls_unroll yes
  for (int i = 0; i < kNumStates; i++)
#pragma hls_unroll yes
    for (int j = 0; j < 256; j++)
      accept[i][j] = false;
  // TODO: these accept states are actually const and should be autogenerated.
  accept[0]['D'] = true; accept[0]['d'] = true;
  accept[1]['o'] = true;
  accept[2]['n'] = true;
  accept[3]['u'] = true;
  accept[4]['t'] = true;
  accept[5]['u'] = true;
  accept[6]['g'] = true;
  accept[7]['h'] = true;
  // TODO: these connections are const and should be autogenerated.
  bool connections[kNumStates][kNumStates];
#pragma hls_unroll yes
  for (int i = 0; i < kNumStates; i++)
#pragma hls_unroll yes
    for (int j = 0; j < kNumStates; j++)
      connections[i][j] = 0;
  connections[0][1] = true;
  connections[1][2] = true; connections[1][5] = true;
  connections[2][3] = true;
  connections[3][4] = true;
  connections[5][6] = true;
  connections[6][7] = true;
  connections[7][2] = true;
  const bool reports[8] = {false, false, false, false,
                        true, false, false, false};

#pragma hls_unroll yes
  for (int i = 0; i < N; i++) {
    bool active_next[kNumStates] = {false, false, false, false,
                              false, false, false, false};
    const char c = stream[i];
#ifndef __SYNTHESIS__
    if (c == 0)
      break;
    std::cout << "Step " << i << ": '" << c << "'" << std::endl;
#endif
#pragma hls_unroll yes
    for (int j = 0; j < kNumStates; j++) {
      if (active_curr[j]) {
#ifndef __SYNTHESIS__
        std::cout << "  state " << j << " is active." << std::endl;
#endif
        if (accept[j][c]) {
          if (reports[j]) {
            result[i][0] = true;
#ifndef __SYNTHESIS__
            std::cout << "    Found match: state " << j << std::endl;
#endif
          }
          // push next set of states into active queue
#pragma hls_unroll yes
          for (int k = 0; k < kNumStates; k++) {
            active_next[k] = connections[j][k];
#ifndef __SYNTHESIS__
            if (active_next[k])
              std::cout << "    Enabling state " << k << " for next cycle." << std::endl;
#endif
          }
        }
      }
    }
#pragma hls_unroll yes
    for (int k = 0; k < kNumStates; k++) {
      active_curr[k] = active_next[k];
      //active_next[k] = false;
    }
  }
} 

#ifndef __SYNTHESIS__
int main(int argc, char ** argv) {
  //const int N = 256;
  //const int kNumStates = 8;
  const int kNumReports = 1;
  bool result[N][kNumReports] = {};
  donut("doughnut", result, N);
  donut("Donut", result, N);
  std::cout << "SUCCESS!" << std::endl;
  return 0;
}
#endif
