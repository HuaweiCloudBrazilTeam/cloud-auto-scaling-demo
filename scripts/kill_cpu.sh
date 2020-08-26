#These scripts come without warranty of any kind. Use them at your own risk. I assume no liability for the accuracy, correctness, completeness, or usefulness of any information provided by this site nor for any sort of damages using these scripts may cause.
#!/bin/bash
stress -c $[$(grep "processor" /proc/cpuinfo | wc -l) * 8] -i 4 --verbose --timeout 15m
