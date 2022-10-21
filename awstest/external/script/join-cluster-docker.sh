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

sudo $(aws ssm get-parameter --name join_command --output text --query "Parameter.Value" | sed -e "s/\\\\//g") --cri-socket=unix:///var/run/cri-dockerd.sock
