# Make sure this script run after k8s-containerd

while true
do
sleep 2s
result=$(aws ssm get-parameter --name join_command --output text --query "Parameter.Value")
echo $result
if [[ "$result" == *"kubeadm"* ]]; then
  echo "breaked"
  break
fi
done


while true
do
sleep 2s
export NODE_NO=$(($(aws ssm get-parameter --name=number_of_workers  --output=text --query="Parameter.Value")+1))
# Each time a node join to cluster, increase this parameter by 1
aws ssm put-parameter --name=number_of_workers  --type=String --value=$NODE_NO --overwrite

result_join=$(sudo $(aws ssm get-parameter --name join_command --output text --query "Parameter.Value" | sed -e "s/\\\\//g") --node-name=worker-$NODE_NO)
echo $result_join
if [[ "$result_join" != *"could not be reached"* ]]; then
  echo "breaked"
  break
fi

kubeadm reset -f
done