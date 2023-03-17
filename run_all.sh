#!/bin/bash

# create multiplier2.circom file with contents from example


# Stop execution if any step returns non-zero (non success) status
set -e

if [ ! $1 ]; then
    echo "You should pass <name> of the existing <name>.circom template to run all. Example: ./run_all.sh multiplier2"
    exit 1
fi

CIRNAME=$1

if [ ! -f ${CIRNAME}.circom ]; then
    echo "${CIRNAME}.circom template desn't exist, exit..."
    exit 2
fi


# set -x

echo "Creating r1cs constraints system, saving to ${CIRNAME}.r1cs"
if [ ! -f ${CIRNAME}_pot_0000.ptau ]
then
    snarkjs powersoftau new bn128 12 ${CIRNAME}_pot_0000.ptau -v
fi

# skip first contribution for tests
# uncomment next line and comment "cp" to add contribution to the trusted setup

# snarkjs powersoftau contribute ${CIRNAME}_pot_0000.ptau ${CIRNAME}_pot_0001.ptau --name="First contribution" -v
cp ${CIRNAME}_pot_0000.ptau ${CIRNAME}_pot_0001.ptau

# generate second part of trusted setup

if [ ! -f ${CIRNAME}_pot_final.ptau ]
then
    snarkjs powersoftau prepare phase2 ${CIRNAME}_pot_0001.ptau ${CIRNAME}_pot_final.ptau -v
fi

echo "Building R1CS for circuit ${CIRNAME}.circom"
if ! circom ${CIRNAME}.circom --r1cs --wasm --sym; then
    echo "${CIRNAME}.circom compilation to r1cs failed. Exiting..."
    exit 1
fi

echo "Info about ${CIRNAME}.circom R1CS constraints system"
snarkjs info -c ${CIRNAME}.r1cs

# echo "Printing constraints
# snarkjs r1cs print ${CIRNAME}.r1cs ${CIRNAME}.sym
snarkjs groth16 setup ${CIRNAME}.r1cs ${CIRNAME}_pot_final.ptau ${CIRNAME}_0000.zkey

# for tests we don't need second contribution
# to enable it - uncomment next line and remove "cp" below
# snarkjs zkey contribute ${CIRNAME}_0000.zkey ${CIRNAME}_0001.zkey --name="1st Contributor Name" -v
echo "Skipping 2-nd contribution, just copy ${CIRNAME}_0000.zkey to ${CIRNAME}_0001.zkey"
cp ${CIRNAME}_0000.zkey ${CIRNAME}_0001.zkey

echo "exporting verification key from ${CIRNAME}_0001.zkey to ${CIRNAME}_verification_key.json"
snarkjs zkey export verificationkey ${CIRNAME}_0001.zkey ${CIRNAME}_verification_key.json

echo "Output size of ${CIRNAME}_verification_key.json"
echo `du -kh "${CIRNAME}_verification_key.json"`


echo "Going to client\'s side into \"${CIRNAME}_js\" folder"
cd ${CIRNAME}_js

# insert construction of inputs here
echo "Create inputs in ${CIRNAME}_input.json"
echo "{\"a\": \"3\", \"b\": \"11\"}" > ${CIRNAME}_input.json

echo "Generate witness from ${CIRNAME}_input.json, using ${CIRNAME}.wasm, saving to ${CIRNAME}_witness.wtns"
node generate_witness.js ${CIRNAME}.wasm ${CIRNAME}_input.json ${CIRNAME}_witness.wtns

echo "Proving that we have a witness (our ${CIRNAME}_input.json in form of ${CIRNAME}_witness.wtn)"
echo "Proof and public signals are saved to ${CIRNAME}_proof.json and ${CIRNAME}_public.json"
/usr/bin/time -f "Prove time: %E" \
    snarkjs groth16 prove ../${CIRNAME}_0001.zkey ${CIRNAME}_witness.wtns ${CIRNAME}_proof.json ${CIRNAME}_public.json

echo "Checking proof of knowledge of private inputs for ${CIRNAME}_public.json using ${CIRNAME}_verification_key.json"
/usr/bin/time -f "Verify time: %E" \
    snarkjs groth16 verify ../${CIRNAME}_verification_key.json ${CIRNAME}_public.json ${CIRNAME}_proof.json

set +x

echo "Output sizes of client's side files":
echo `du -kh "../${CIRNAME}_verification_key.json"`
echo `du -kh "${CIRNAME}.wasm"`
echo `du -kh "${CIRNAME}_witness.wtns"`




