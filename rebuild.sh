tag=rjones30/gluexpro8:latest
docker build --tag $tag .
if [[ $? == 0 ]]; then
    echo -n "docker build --tag $tag completed successfully, to update the image "
    echo "on dockerhub you need to follow up with the command below."
    echo "$ sudo docker push $tag"
else
    echo -n "docker build --tag $tag failed, please fix the problems before you "
    echo "push the updates to dockerhub."
fi
