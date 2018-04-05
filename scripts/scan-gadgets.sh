#!/bin/bash

if [[ $# != 0 ]] ; then
	echo "usage: plv scan-libc"
	exit 1
fi

#!/bin/bash

# Look for these common gadgets
gadgets=($'\x5a\xc3' $'\x5e\xc3' $'\x5f\xc3')

# Look in this library
testfile=/usr/lib64/libc-2.17.so

# Make a temporary file to extract the .text section into
tempfile=$(mktemp -t objcopy.XXXXXX)

# Extract the .text section into the temp file
objcopy -O binary --only-section=.text ${testfile} ${tempfile}

# Loop over all gadgets and find the first occurance
for gadget in "${gadgets[@]}"; do
        signature+=$(printf "0x%07x " $(grep -abo ${gadget} -m 1 ${tempfile} | head -n 1 | cut -d':' -f1))
done

echo "GADGETS: File: ${testfile}, Signature: ${signature}"

# Delete the temp file
rm ${tempfile}
