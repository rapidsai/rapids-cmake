#include <iostream>

int static_launch_kernelA(int x, int y);

int main(int argc, char**)
{
  auto resultA = static_launch_kernelA(3, argc);

  if (resultA != 6) { return 1; }

  return 0;
}
