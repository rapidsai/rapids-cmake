/*
 * Copyright (c) 2022-2023, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cuda_runtime_api.h>

#include <iostream>
#include <string>
#include <vector>

struct version {
  int major = 1;
  int minor = 0;
};

struct gpu {
  gpu(int i) : id{i} {};
  gpu(int i, const cudaDeviceProp& prop) : id{i}, memory{prop.totalGlobalMem}, slots{100} {}
  int id        = 0;
  size_t memory = 0;
  int slots     = 0;
};

// A hard-coded JSON printer that generates a ctest resource-specification file:
// https://cmake.org/cmake/help/latest/manual/ctest.1.html#resource-specification-file
void to_json(std::ostream& buffer, version const& v)
{
  buffer << "\"version\": {\"major\": " << v.major << ", \"minor\": " << v.minor << "}";
}
void to_json(std::ostream& buffer, gpu const& g)
{
  buffer << "\t\t{\"id\": \"" << g.id << "\", \"slots\": " << g.slots << "}";
}

int main()
{
  std::vector<gpu> gpus;
  int nDevices = 0;
  cudaGetDeviceCount(&nDevices);
  if (nDevices == 0) {
    gpus.emplace_back(0);
  } else {
    for (int i = 0; i < nDevices; ++i) {
      cudaDeviceProp prop;
      cudaGetDeviceProperties(&prop, i);
      gpus.emplace_back(i, prop);
    }
  }

  version v{1, 0};
  std::cout << "{\n";
  to_json(std::cout, v);
  std::cout << ",\n";
  std::cout << "\"local\": [{\n";
  std::cout << "\t\"gpus\": [\n";
  for (int i = 0; i < gpus.size(); ++i) {
    to_json(std::cout, gpus[i]);
    if (i != (gpus.size() - 1)) { std::cout << ","; }
    std::cout << "\n";
  }
  std::cout << "\t]\n";
  std::cout << "}]\n";
  std::cout << "}" << std::endl;
  return 0;
}
