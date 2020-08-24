DIR=$1
if [[ $DIR == "up" ]]; then
    rsync --update --recursive \
        --exclude ".git" --exclude "config/" --progress \
        -e "ssh -p 3128" ./ daniel@r1.ada.arrakis.it:~/cardano-node-docker/

    rsync --update --recursive \
        --exclude ".git" --exclude "config/" --progress \
        -e "ssh -p 3128" ./ daniel@p1.ada.arrakis.it:~/cardano-node-docker/
fi

if [[ $DIR == "down" ]]; then
    rsync --update --recursive \
        --exclude ".git" --exclude "config/" --progress \
        -e "ssh -p 3128" do@35.214.254.235:~/cardano-node-docker/private/ ./
fi