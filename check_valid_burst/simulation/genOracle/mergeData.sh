cat data_good1_cos.dat > input_oracle_cos.dat
cat data_good2_cos.dat >> input_oracle_cos.dat
cat data_bad3_cos.dat >> input_oracle_cos.dat
cat data_good4_cos.dat >> input_oracle_cos.dat
cat ../real_data.dat | awk '{print $2}' >> input_oracle_cos.dat

cat data_good1_sin.dat > input_oracle_sin.dat
cat data_good2_sin.dat >> input_oracle_sin.dat
cat data_bad3_sin.dat >> input_oracle_sin.dat
cat data_good4_sin.dat >> input_oracle_sin.dat
cat ../real_data.dat | awk '{print $1}' >> input_oracle_sin.dat

cat oracle_data_good1.dat > oracle_data.dat
echo "eof" >> oracle_data.dat
cat oracle_data_good2.dat >> oracle_data.dat
echo "eof" >> oracle_data.dat
cat oracle_data_bad3.dat >> oracle_data.dat
echo "eof" >> oracle_data.dat
cat oracle_data_good4.dat >> oracle_data.dat
echo "eof" >> oracle_data.dat
cat ../real_data.dat >> oracle_data.dat
echo "eof" >> oracle_data.dat
