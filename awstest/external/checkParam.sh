while true
do
sleep 2s
result=$(aws ssm get-parameter --name join_command2 --output text --query "Parameter.Value")
echo $result
if [[ "$result" == *"kubeadm"* ]]; then
  echo "breaked"
  break
fi
done