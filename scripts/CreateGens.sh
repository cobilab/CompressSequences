#rm sequence_model.fasta
#rm shuffled.fasta.gz
#rm ordered_sequence_model_size.fasta.gz
#rm ordered_sequence_model_AT.fasta.gz
#rm ordered_sequence_model_CG.fasta.gz
#rm ordered_shuffled_size.fasta.gz
#rm ordered_shuffled_AT.fasta.gz
#rm ordered_shuffled_CG.fasta.gz
#rm sort_fanalysis.fasta.gz
#rm sort.fa.gz
#rm sequence_model.fasta.gz

OUT_FILE="alcorGen_multifasta.fa";

read -p "Define the lowest sequence size to be considered " LOWEST_SIZE
read -p "Define the increment factor to be used on sequence sizes " INCREMENT_FACTOR
#read -p "Define the number of different sequences sizes to be considered: " SIZE_NUMBER
read -p "Define the seed range: " SEED_RANGE

#echo "The first $SEED_RANGE prime numbers  are: "
declare -a seed_arr=()
declare -a size_arr=()

rm -fr $OUT_FILE

m=2
while [  ${#seed_arr[@]}  -lt $SEED_RANGE ]
do
i=2
flag=0
while [ $i -le `expr $m / 2` ]
do
if [ `expr $m % $i` -eq 0 ]
then
flag=1
break
fi
i=`expr $i + 1`
done
if [ $flag -eq 0 ]
then
#echo $m
seed_arr+=($m)
#echo ${#seed_arr[@]}  
fi
m=`expr $m + 1`
done

for((i=0;i<${#seed_arr[@]}; i++ ))
do
  echo ${seed_arr[$i]} #> prime_numbers.txt
done

INCREMENT=0
#for x in {1..$SIZE_NUMBER}
size=$((LOWEST_SIZE))
for((x=1;x<=$SEED_RANGE; x++ ))
do 
j=$(($x-1)) 
size=$(($size+$INCREMENT))
echo $
# echo $size
 #echo ${seed_arr[x]}
 seed=${seed_arr[$j]}
 size_arr+=($size)
 INCREMENT=$(($INCREMENT_FACTOR*$LOWEST_SIZE))
 #echo $seed
 #echo $size
 ./AlcoR simulation -rs  $size:0:$seed:0:0:0 > alcorGen_$x.fa
done

#for x in {0...$SEED_RANGE}
echo ${#seed_arr[@]}

size=$((LOWEST_SIZE))
INCREMENT=0
#echo $size
for((x=1;x<=${#seed_arr[@]}; x++ ))
do
j=$(($x-1))
size=$(($size+$INCREMENT))
INCREMENT=$(($INCREMENT_FACTOR*$LOWEST_SIZE))
 for y in {0..1}
 do
   #for z in {1..$SIZE_NUMBER}
   for((z=1;z<=$SEED_RANGE;z++ ))
   #for((z=$SEED_RANGE;z<=1; z-- ))
   do
  # echo $x
   s=$(($z-1)) 

   #size=$(($LOWEST_SIZE*$INCREMENT_FACTOR*$z))
    #size=$((1000*$z))
    #echo 
    #seed=$(${seed_arr[x]})
   #if [ $z -gt $j ]
   #the

   # From equation:
    #$size= $lowest_size + ($z-1)* ($INCREMENT_FACTOR) * ($lowest_size)
    #we get:
    size_diff=$(($size-$LOWEST_SIZE))
    valid_z=$(echo $(($size_diff/$INCREMENT)))
    valid_z=$(($valid_z + 1))
  
  echo $valid_z
   echo $size " : " $s
   #echo "$size"
   if [ $size -eq $LOWEST_SIZE ] 
   then
    ./AlcoR simulation -fs 1:$size:0:${seed_arr[$s]}:0.0$y:0:0:alcorGen_$z.fa >> $OUT_FILE
  else
    if [ $z -gt $valid_z ]
    then
    ./AlcoR simulation -fs 1:$size:0:${seed_arr[$s]}:0.0$y:0:0:alcorGen_$z.fa >> $OUT_FILE
    fi
  fi
  #fi
        done
       done
     done
####    
sed -i '/^$/d' $OUT_FILE
