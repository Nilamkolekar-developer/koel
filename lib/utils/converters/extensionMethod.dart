extension ComparableExtension<T extends Comparable<T>> on T {
  T clampCustom(T min, T max) {
    if (this.compareTo(min) < 0) return min;
    if (this.compareTo(max) > 0) return max;
    return this;
  }
}

// Usage:
void main() {
  int myNum = 25;
  //print(myNum.clampCustom(1, 10)); // Output: 10
  
  String myLetter = 'z';
  print(myLetter.clampCustom('a', 'm')); // Output: m
}